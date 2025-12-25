### WhatsApp Integration (Kapso)

**Kapso** provides WhatsApp messaging capabilities through two integration approaches:

**1. WhatsApp Cloud API** (Direct messaging from your app):
- `src/lib/kapso.ts` – Kapso client configuration
- `src/app/actions/whatsapp.ts` – Server actions for sending messages
- `src/components/whatsapp-message-form.tsx` – Example component for sending messages

**2. Platform API** (Multi-tenant: customers connect their own WhatsApp):
- `src/lib/kapso.ts` – Platform API helpers (`kapsoPlatformFetch`, `createKapsoCustomer`, etc.)
- `src/app/actions/kapso-platform.ts` – Server actions for customer onboarding
- `src/components/kapso-platform-example.tsx` – Example component for customer onboarding

**Configuration**:
- Set `KAPSO_API_KEY` in your environment variables (get it from https://app.kapso.ai)
- Free tier: 5,000 messages per month
- See `.env.example` for setup template

**Use Cases**:
- **Direct API**: Send appointment reminders, order updates, notifications from your app
- **Platform API**: Enable customers to connect their WhatsApp Business accounts for multi-tenant scenarios (CRMs, booking platforms, marketing tools)

**Documentation**: https://docs.kapso.ai