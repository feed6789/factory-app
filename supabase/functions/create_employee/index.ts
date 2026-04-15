import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // 1. Xử lý CORS cho Flutter Web/App
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 2. Lấy JWT Token từ Flutter gửi lên
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      throw new Error('Thiếu Authorization header')
    }

    // 3. Khởi tạo Client đại diện cho user đang bấm nút
    const supabaseUserClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )

    // 4. Kiểm tra xem user này có phải Admin không
    const { data: { user }, error: userError } = await supabaseUserClient.auth.getUser()
    if (userError || !user) throw new Error('Token không hợp lệ')

    const { data: profile } = await supabaseUserClient
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single()

    if (profile?.role !== 'admin') {
      return new Response(JSON.stringify({ error: 'Chỉ Admin mới được tạo nhân viên.' }), { status: 403, headers: corsHeaders })
    }

    // 5. Nếu đúng là Admin -> Dùng quyền tối cao để tạo tài khoản mới
    const { email, password, fullName, empCode, role, phoneNumber } = await req.json()

    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { auth: { autoRefreshToken: false, persistSession: false } }
    )

    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email: email,
      password: password,
      email_confirm: true,
    })
    if (authError) throw authError

    const userId = authData.user.id

    const { error: profileError } = await supabaseAdmin.from('profiles').insert({
      id: userId,
      full_name: fullName,
      employee_code: empCode,
      role: role,
      email: email,
      phone_number: phoneNumber,
      is_active: true,
    })

    if (profileError) {
      await supabaseAdmin.auth.admin.deleteUser(userId)
      throw profileError
    }
    
    return new Response(JSON.stringify({ message: 'User created successfully' }), {
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