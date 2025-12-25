## Important Patterns

1. **Utility imports**:
   ```ts
   import { cn } from "@/lib/utils";
   ```

2. **Server Actions with proper validation**:
   ```ts
   "use server";

   import { db } from "@/db";
   import { revalidatePath } from "next/cache";
   import { z } from "zod";

   const createPostSchema = z.object({
     title: z.string().min(1),
   });

   export async function createPost(formData: FormData) {
     const parsed = createPostSchema.parse({
       title: formData.get("title"),
     });

     await db.insert(posts).values(parsed);

     revalidatePath("/posts");
   }
   ```