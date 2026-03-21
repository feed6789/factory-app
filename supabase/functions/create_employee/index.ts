// File: supabase/functions/create_employee/index.ts
// ĐÃ ĐƯỢC SỬA LỖI CORS

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Định nghĩa các header cho phép CORS. Dùng biến này để tránh lặp lại code.
const corsHeaders = {
  'Access-Control-Allow-Origin': '*', // Cho phép TẤT CẢ các nguồn gọi. Để an toàn hơn, bạn có thể thay '*' bằng 'https://ung-dung-nm.web.app'
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // --- PHẦN QUAN TRỌNG NHẤT ĐỂ SỬA LỖI ---
  // Trình duyệt sẽ gửi một yêu cầu 'OPTIONS' trước (gọi là preflight request) để kiểm tra quyền.
  // Chúng ta phải trả lời OK cho yêu cầu này.
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }
  // ------------------------------------------

  try {
    const { email, password, fullName, empCode, role, phoneNumber } = await req.json()

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
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
      email: email, // <--- THÊM DÒNG NÀY
      phone_number: phoneNumber, // <--- THÊM DÒNG NÀY
      is_active: true,
    })

    if (profileError) {
      await supabaseAdmin.auth.admin.deleteUser(userId)
      throw profileError
    }
    
    // Thêm corsHeaders vào response thành công
    return new Response(JSON.stringify({ message: 'User created successfully' }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (error) {
    // Thêm corsHeaders vào response lỗi
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})