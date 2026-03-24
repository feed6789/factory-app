import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { user_id, new_email, new_password } = await req.json()
    if (!user_id) throw new Error('Cần có user_id')

    // Khởi tạo Supabase Admin Client bằng Service Role Key
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Chuẩn bị dữ liệu cập nhật
    const updates: any = {}
    if (new_password && new_password.trim() !== '') {
      updates.password = new_password
    }
    if (new_email && new_email.trim() !== '') {
      updates.email = new_email
      updates.email_confirm = true // Bỏ qua bước gửi email xác nhận vì Admin đổi
    }

    // Nếu không có gì để cập nhật về auth thì bỏ qua
    if (Object.keys(updates).length > 0) {
      const { error: authError } = await supabaseAdmin.auth.admin.updateUserById(
        user_id,
        updates
      )
      if (authError) throw authError
    }

    return new Response(JSON.stringify({ message: 'Cập nhật Auth thành công' }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})