import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // 1. Xử lý CORS cho Flutter Web
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 2. Lấy JWT Token & Kiểm tra quyền Admin
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) throw new Error('Thiếu Authorization header')

    const supabaseUserClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )

    const { data: { user }, error: userError } = await supabaseUserClient.auth.getUser()
    if (userError || !user) throw new Error('Token không hợp lệ')

    const { data: profile } = await supabaseUserClient
      .from('profiles').select('role').eq('id', user.id).single()

    if (profile?.role !== 'admin') {
      return new Response(JSON.stringify({ error: 'Chỉ Admin mới được đổi thông tin đăng nhập.' }), { status: 403, headers: corsHeaders })
    }

    // 3. Xử lý logic Update Credentials bằng Service Role Key
    const body = await req.json()
    const { user_id, new_email, new_password } = body

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      { auth: { autoRefreshToken: false, persistSession: false } }
    )

    const updateData: Record<string, any> = {}
    if (new_email) updateData.email = new_email
    if (new_password) updateData.password = new_password

    // Gọi API của Supabase để update Auth User
    const { error: updateError } = await supabaseAdmin.auth.admin.updateUserById(user_id, updateData)
    if (updateError) throw updateError

    return new Response(JSON.stringify({ message: 'Cập nhật tài khoản thành công!' }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })

  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { 
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  }
})