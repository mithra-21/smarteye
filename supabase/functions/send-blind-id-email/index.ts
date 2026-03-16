// ============================================================
// Supabase Edge Function: send-blind-id-email
// ============================================================
// Sends the auto-generated Blind ID to the caretaker's email.
//
// DEPLOYMENT:
//   1. Install Supabase CLI: npm install -g supabase
//   2. Run: supabase functions deploy send-blind-id-email
//   3. Set up your SMTP secrets (see below)
//
// REQUIRED SECRETS (set via Supabase Dashboard → Edge Functions → Secrets):
//   SMTP_HOST      — e.g. smtp.gmail.com
//   SMTP_PORT      — e.g. 587
//   SMTP_USER      — your email address
//   SMTP_PASS      — app password (Gmail: generate at myaccount.google.com)
//   SMTP_FROM      — sender email (e.g. smarteye@yourapp.com)
//
// ============================================================
// NOTE: If you don't want to deploy Edge Functions right now,
// this will fail gracefully — the blind ID is still saved in the
// DB and shown in-app. You can deploy this later.
// ============================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { SmtpClient } from "https://deno.land/x/smtp@v0.7.0/mod.ts";

serve(async (req: Request) => {
  try {
    const { caretaker_email, blind_id, blind_user_name } = await req.json();

    if (!caretaker_email || !blind_id) {
      return new Response(
        JSON.stringify({ error: "Missing caretaker_email or blind_id" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const client = new SmtpClient();

    await client.connectTLS({
      hostname: Deno.env.get("SMTP_HOST") || "smtp.gmail.com",
      port: Number(Deno.env.get("SMTP_PORT")) || 587,
      username: Deno.env.get("SMTP_USER") || "",
      password: Deno.env.get("SMTP_PASS") || "",
    });

    const userName = blind_user_name || "A SmartEye User";

    await client.send({
      from: Deno.env.get("SMTP_FROM") || Deno.env.get("SMTP_USER") || "",
      to: caretaker_email,
      subject: `SmartEye — Your Blind User ID: ${blind_id}`,
      content: `
        <div style="font-family: Arial, sans-serif; max-width: 500px; margin: 0 auto; padding: 30px;">
          <h2 style="color: #E91E63;">SmartEye</h2>
          <p>Hello,</p>
          <p><strong>${userName}</strong> has registered as a blind user on SmartEye and listed you as their caretaker.</p>
          <p>To link your caretaker account, use this <strong>Blind User ID</strong> during sign-up:</p>
          <div style="background: #1A111A; color: #FF4081; padding: 20px; border-radius: 12px; text-align: center; margin: 20px 0;">
            <span style="font-size: 32px; font-weight: bold; letter-spacing: 6px;">${blind_id}</span>
          </div>
          <p style="color: #666; font-size: 14px;">
            Open the SmartEye app → Caretaker Sign Up → Enter this ID in the "Blind User ID" field.
          </p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
          <p style="color: #999; font-size: 12px;">This is an automated message from SmartEye. Do not reply.</p>
        </div>
      `,
      html: true,
    });

    await client.close();

    return new Response(
      JSON.stringify({ success: true, message: "Email sent successfully" }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Email send error:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
