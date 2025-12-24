#!/usr/bin/env bash
#
# parallel.sh - Parallel Claude execution framework for codebase operations
#
# This file contains:
# - Interactive mode (tmux-based) execution
# - Background mode execution with concurrency limiting
# - Process tracking and completion detection
#
# Requires: logging.sh, modes/base.sh (for get_task_prompt)
# Expects: CREATED_WORKTREES, GROUPS_FILE, MODE_CONFIG, MAX_PARALLEL_CLAUDE, FIXING_MODEL,
#          QUESTIONS_DIR, LOG_DIR, TIMESTAMP, PIDS_FILE

# =============================================================================
# PARALLEL EXECUTION - INTERACTIVE (TMUX)
# =============================================================================

run_parallel_tasks_interactive() {
	log "INFO" "=========================================="
	log "INFO" "PHASE 3: INTERACTIVE TASK EXECUTION (tmux)"
	log "INFO" "=========================================="

	local mode_name="${MODE_CONFIG[name]:-Task}"
	local session_name="${MODE_CONFIG[branch_prefix]:-fix}_tasks_${TIMESTAMP}"
	local worktree_count=${#CREATED_WORKTREES[@]}

	# Kill existing session if present
	tmux kill-session -t "$session_name" 2>/dev/null || true

	# Auto-detect layout: split panes for <=4 worktrees, windows for more
	local use_splits=false
	if [[ $worktree_count -le 4 ]]; then
		use_splits=true
		log "INFO" "Using split panes layout (${worktree_count} worktrees)"
	else
		log "INFO" "Using windows layout (${worktree_count} worktrees)"
	fi

	# Create new tmux session with first worktree
	local first_worktree="${CREATED_WORKTREES[0]}"
	local first_branch
	first_branch=$(git -C "$first_worktree" rev-parse --abbrev-ref HEAD)
	local first_questions="${QUESTIONS_DIR}/${first_branch//\//_}_questions.md"

	# Extract group name from branch
	local first_group_name="${first_branch#${MODE_CONFIG[branch_prefix]:-fix}/}"
	first_group_name="${first_group_name#[0-9][0-9]-}"

	# Get complexity for model selection
	local first_complexity
	first_complexity=$(jq -r ".groups[] | select(.name == \"$first_group_name\") | .estimated_complexity" "${GROUPS_FILE:-$BUG_GROUPS_FILE}")
	local first_model="${FIXING_MODEL:-sonnet}"
	if [[ "$first_complexity" == "simple" ]] || [[ "$first_complexity" == "quick-win" ]] || [[ "$first_complexity" == "trivial" ]]; then
		first_model="haiku"
	fi

	log "INFO" "Creating tmux session: $session_name"

	# Get task prompt using mode-specific function
	local first_prompt
	first_prompt=$(get_task_prompt "$first_group_name" "$first_questions")

	tmux new-session -d -s "$session_name" -c "$first_worktree" \
		"claude --model $first_model '$first_prompt'; echo 'Press Enter to close...'; read"

	if [[ "$use_splits" == true ]]; then
		# Split pane mode: create panes in a tiled layout
		for ((i = 1; i < worktree_count; i++)); do
			local worktree="${CREATED_WORKTREES[$i]}"
			local branch_name
			branch_name=$(git -C "$worktree" rev-parse --abbrev-ref HEAD)
			local questions_file="${QUESTIONS_DIR}/${branch_name//\//_}_questions.md"

			local group_name_clean="${branch_name#${MODE_CONFIG[branch_prefix]:-fix}/}"
			group_name_clean="${group_name_clean#[0-9][0-9]-}"

			local complexity
			complexity=$(jq -r ".groups[] | select(.name == \"$group_name_clean\") | .estimated_complexity" "${GROUPS_FILE:-$BUG_GROUPS_FILE}")
			local model="${FIXING_MODEL:-sonnet}"
			if [[ "$complexity" == "simple" ]] || [[ "$complexity" == "quick-win" ]] || [[ "$complexity" == "trivial" ]]; then
				model="haiku"
			fi

			local task_prompt
			task_prompt=$(get_task_prompt "$group_name_clean" "$questions_file")

			# Split and run claude in new pane
			tmux split-window -t "$session_name" -c "$worktree" \
				"claude --model $model '$task_prompt'; echo 'Press Enter to close...'; read"

			# Rebalance to tiled layout after each split
			tmux select-layout -t "$session_name" tiled
		done

		# Set final tiled layout
		tmux select-layout -t "$session_name" tiled

		# Select first pane
		tmux select-pane -t "$session_name:0.0"
	else
		# Window mode: create separate windows
		tmux rename-window -t "${session_name}:0" "$(basename "$first_worktree")"

		for ((i = 1; i < worktree_count; i++)); do
			local worktree="${CREATED_WORKTREES[$i]}"
			local branch_name
			branch_name=$(git -C "$worktree" rev-parse --abbrev-ref HEAD)
			local questions_file="${QUESTIONS_DIR}/${branch_name//\//_}_questions.md"

			local group_name_clean="${branch_name#${MODE_CONFIG[branch_prefix]:-fix}/}"
			group_name_clean="${group_name_clean#[0-9][0-9]-}"

			local complexity
			complexity=$(jq -r ".groups[] | select(.name == \"$group_name_clean\") | .estimated_complexity" "${GROUPS_FILE:-$BUG_GROUPS_FILE}")
			local model="${FIXING_MODEL:-sonnet}"
			if [[ "$complexity" == "simple" ]] || [[ "$complexity" == "quick-win" ]] || [[ "$complexity" == "trivial" ]]; then
				model="haiku"
			fi

			local task_prompt
			task_prompt=$(get_task_prompt "$group_name_clean" "$questions_file")

			tmux new-window -t "$session_name" -c "$worktree" -n "$(basename "$worktree")" \
				"claude --model $model '$task_prompt'; echo 'Press Enter to close...'; read"
		done

		# Create a status window (only in window mode)
		tmux new-window -t "$session_name" -n "status" \
			"watch -n 5 'echo \"=== Questions/Blockers ===\"; cat ${QUESTIONS_DIR}/*_questions.md 2>/dev/null || echo \"No questions yet\"; echo; echo \"=== Commits ===\"; for wt in ${CREATED_WORKTREES[*]}; do echo \"\$(basename \$wt): \$(git -C \$wt rev-list --count main..HEAD 2>/dev/null || echo 0) commits\"; done'"
	fi

	log "INFO" "=========================================="
	log "INFO" "INTERACTIVE MODE STARTED"
	log "INFO" "=========================================="
	log "INFO" ""
	log "INFO" "Tmux session: $session_name (${worktree_count} Claude instances)"
	log "INFO" ""
	log "INFO" "To attach:"
	log "INFO" "  tmux attach -t $session_name"
	log "INFO" ""
	if [[ "$use_splits" == true ]]; then
		log "INFO" "Navigation (split panes):"
		log "INFO" "  Ctrl+b arrow  - Move between panes"
		log "INFO" "  Ctrl+b z      - Toggle pane zoom (fullscreen)"
		log "INFO" "  Ctrl+b d      - Detach"
	else
		log "INFO" "Navigation (windows):"
		log "INFO" "  Ctrl+b n/p    - Next/prev window"
		log "INFO" "  Ctrl+b 0-9    - Go to window number"
		log "INFO" "  Ctrl+b d      - Detach"
	fi
	log "INFO" ""
	log "INFO" "When done, run: ./codebase_ops.sh --mode ${MODE_CONFIG[branch_prefix]:-fix} --continue"
	log "INFO" "To abort: tmux kill-session -t $session_name"
	log "INFO" "=========================================="

	# Save session name for --continue
	echo "$session_name" > "${LOG_DIR}/current_session.txt"
	echo "${GROUPS_FILE:-$BUG_GROUPS_FILE}" > "${LOG_DIR}/current_groups.txt"

	# Ask if user wants to attach now (only if interactive shell)
	if [[ -t 0 ]]; then
		read -p "Attach to tmux session now? (Y/n): " attach_now
		if [[ "$attach_now" != "n" && "$attach_now" != "N" ]]; then
			tmux attach -t "$session_name"
		fi
	else
		log "INFO" "Non-interactive shell detected, skipping auto-attach"
		log "INFO" "Run: tmux attach -t $session_name"
	fi
}

# =============================================================================
# PARALLEL EXECUTION - BACKGROUND
# =============================================================================

run_parallel_tasks_background() {
	log "INFO" "=========================================="
	log "INFO" "PHASE 3: PARALLEL TASK EXECUTION (background)"
	log "INFO" "=========================================="

	if [[ ${#CREATED_WORKTREES[@]} -eq 0 ]]; then
		log "INFO" "No worktrees to process"
		return 0
	fi

	> "$PIDS_FILE" # Clear PIDs file

	declare -A worktree_pids   # Associative array: worktree_path -> pid
	declare -A worktree_logs   # Associative array: worktree_path -> log_file
	local active_count=0       # Manual count of active processes

	local max_parallel="${MAX_PARALLEL_CLAUDE:-5}"
	log "INFO" "Launching Claude instances with concurrency limit: $max_parallel"

	local worktree_index=0
	local total_worktrees=${#CREATED_WORKTREES[@]}

	for worktree in "${CREATED_WORKTREES[@]}"; do
		# Wait if we've reached the concurrency limit
		while [[ $active_count -ge $max_parallel ]]; do
			# Check for completed processes
			if [[ $active_count -gt 0 ]]; then
				for wt in "${!worktree_pids[@]}"; do
					local pid=${worktree_pids[$wt]}
					if ! kill -0 "$pid" 2>/dev/null; then
						# Process completed, remove from tracking
						wait "$pid" || true
						unset "worktree_pids[$wt]"
						active_count=$((active_count - 1))
						log "INFO" "  Claude completed for: $(basename "$wt")"
					fi
				done
			fi
			sleep 1
		done

		local branch_name log_file questions_file
		branch_name=$(git -C "$worktree" rev-parse --abbrev-ref HEAD)
		log_file="${LOG_DIR}/claude_${branch_name//\//_}_${TIMESTAMP}.log"
		questions_file="${QUESTIONS_DIR}/${branch_name//\//_}_questions.md"

		# Extract group name from branch
		local group_name_clean="${branch_name#${MODE_CONFIG[branch_prefix]:-fix}/}"
		group_name_clean="${group_name_clean#[0-9][0-9]-}"

		# Determine model based on complexity
		local complexity
		complexity=$(jq -r ".groups[] | select(.name == \"$group_name_clean\") | .estimated_complexity" "${GROUPS_FILE:-$BUG_GROUPS_FILE}")

		local task_prompt
		task_prompt=$(get_task_prompt "$group_name_clean" "$questions_file")

		local model="${FIXING_MODEL:-sonnet}"
		if [[ "$complexity" == "simple" ]] || [[ "$complexity" == "quick-win" ]] || [[ "$complexity" == "trivial" ]]; then
			model="haiku"  # Simple tasks use Haiku (cost savings)
		fi

		worktree_index=$((worktree_index + 1))
		log "INFO" "Launching Claude [$worktree_index/$total_worktrees]: $worktree (complexity: $complexity, model: $model)"

		# Run Claude in background
		(
			cd "$worktree"
			claude --print \
				--dangerously-skip-permissions \
				--model "$model" \
				"$task_prompt" > "$log_file" 2>&1
		) &

		local pid=$!
		echo "$pid" >> "$PIDS_FILE"
		worktree_pids["$worktree"]=$pid
		worktree_logs["$worktree"]=$log_file
		active_count=$((active_count + 1))

		log "INFO" "  Started Claude PID $pid ($active_count/$max_parallel slots used)"
	done

	# Wait for all Claude processes
	log "INFO" "Waiting for $active_count Claude instances to complete..."
	log "INFO" "This may take a while."
	log "INFO" ""
	log "INFO" "Monitor progress:"
	log "INFO" "  - Logs: tail -f ${LOG_DIR}/claude_*.log"
	log "INFO" "  - Questions: cat ${QUESTIONS_DIR}/*_questions.md"
	log "INFO" ""

	local failed=0
	for worktree in "${!worktree_pids[@]}"; do
		local pid=${worktree_pids[$worktree]}
		local log_file=${worktree_logs[$worktree]}

		log "INFO" "Waiting for PID $pid ($(basename "$worktree"))..."

		if wait "$pid"; then
			log "INFO" "Claude completed successfully for: $(basename "$worktree")"

			# Check if there are any commits
			local commits
			commits=$(git -C "$worktree" rev-list --count main..HEAD 2>/dev/null || echo "0")
			if [[ "$commits" -gt 0 ]]; then
				log "INFO" "  $commits commit(s) made"
			else
				log "WARN" "  No commits made - task may not have been completed"
			fi
		else
			log "ERROR" "Claude failed for: $(basename "$worktree") (exit code: $?)"
			log "ERROR" "  See log: $log_file"
			((failed++))
		fi
	done

	if [[ $failed -gt 0 ]]; then
		log "WARN" "$failed Claude instance(s) failed. Continuing with successful ones..."
	fi

	# Check for any questions/blockers
	check_for_questions
}

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Check for questions/blockers from Claude instances
check_for_questions() {
	local has_questions=false
	for q_file in "${QUESTIONS_DIR}"/*_questions.md; do
		if [[ -f "$q_file" && -s "$q_file" ]]; then
			has_questions=true
			break
		fi
	done

	if [[ "$has_questions" == true ]]; then
		log "WARN" "=========================================="
		log "WARN" "QUESTIONS/BLOCKERS DETECTED"
		log "WARN" "=========================================="
		log "WARN" ""
		log "WARN" "Some Claude instances encountered questions or blockers."
		log "WARN" "Review them at: ${QUESTIONS_DIR}/"
		log "WARN" ""

		# Display questions
		for q_file in "${QUESTIONS_DIR}"/*_questions.md; do
			if [[ -f "$q_file" && -s "$q_file" ]]; then
				log "WARN" "--- $(basename "$q_file") ---"
				while IFS= read -r line; do
					log "WARN" "  $line"
				done < "$q_file"
				log "WARN" ""
			fi
		done

		if [[ -t 0 ]] && [[ "${AUTO_MERGE:-false}" != true ]]; then
			read -p "Continue with merging anyway? (y/N): " continue_merge
			if [[ "$continue_merge" != "y" && "$continue_merge" != "Y" ]]; then
				log "INFO" "Aborting. Review questions and run with --continue when ready."
				exit 0
			fi
		elif [[ "${AUTO_MERGE:-false}" != true ]]; then
			log "WARN" "Non-interactive shell - aborting due to questions/blockers"
			log "INFO" "Review questions and run with --continue when ready."
			exit 0
		fi
	fi
}

# Main entry point - choose between interactive and background
run_parallel_tasks() {
	# Create questions directory
	mkdir -p "${QUESTIONS_DIR}"

	if [[ "${INTERACTIVE:-true}" == true ]]; then
		run_parallel_tasks_interactive
		# In interactive mode, we exit here and user runs --continue later
		exit 0
	else
		run_parallel_tasks_background
	fi
}
