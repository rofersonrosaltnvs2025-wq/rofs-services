ROFS SERVICES — Supabase login/database setup

FILES
- index.html: existing dashboard design/services, now protected by Supabase login and connected to the orders table.
- login.html: customer login + open self-registration.
- admin-login.html: separate administrator login; checks the database role before entering.
- supabase-config.js: paste your Supabase project URL and anon/publishable key here.
- supabase-schema.sql: database tables, new-user profile trigger, and Row Level Security (RLS) policies.

SETUP (beginner-friendly)
1. Create a project at https://supabase.com/ and wait for it to finish provisioning.
2. In Project Settings > API (or Connect), copy the Project URL and the anon/public/publishable key. Put them into supabase-config.js. NEVER use the service_role/secret key in browser files.
3. Open SQL Editor in Supabase, create a new query, paste all of supabase-schema.sql, and Run.
4. In Authentication > URL Configuration, set Site URL to your deployed website URL (for example your Vercel production URL) and add Redirect URLs for the same URL and local preview if you use one.
5. Deploy all five files to the same Vercel project/root folder. Ensure index.html is the homepage.
6. Open login.html and create your customer account. If email confirmation is enabled, confirm the email before login.
7. To make your own account admin, in Supabase SQL Editor run the final commented UPDATE statement in supabase-schema.sql after replacing you@example.com with your registered email. Then open admin-login.html and sign in with that account.
8. Test: create a test order with a customer account; log in using the admin page in a separate browser/incognito window; confirm admin can see/update/delete orders and customer only sees their own orders.

SECURITY NOTES
- Customer signup is open, but new accounts are always assigned role=customer by the database trigger.
- Admin role is set only through the Supabase SQL Editor. Do not add any client-side “make admin” button.
- Row Level Security (RLS) is the actual data protection. Hiding the Admin Panel in HTML is only a UI measure.
- Existing localStorage/demo orders are not imported. The old sample order was removed so fake sample data is not mistaken for a real customer order.
- This is a starter integration. Before handling sensitive payment/card details, never collect full card numbers or CVV in this site; use a compliant payment provider checkout.
- If the app is hosted under a subfolder rather than the domain root, adjust the relative links (./login.html, ./admin-login.html).

TROUBLESHOOTING
- “Setup required”: supabase-config.js still has placeholder values or a typo.
- Registration succeeds but no login: check email confirmation settings/inbox.
- Admin page says not authorized: run the role UPDATE after the account exists; ensure email is exact.
- Orders fail: check that supabase-schema.sql ran successfully and RLS is enabled/policies exist.
