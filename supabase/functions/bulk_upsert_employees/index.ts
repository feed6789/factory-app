import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // 1. Xử lý CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 2. Lấy Token & Kiểm tra Admin
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
      return new Response(JSON.stringify({ error: 'Chỉ Admin mới được Import CSV.' }), { status: 403, headers: corsHeaders })
    }

    // 3. Khởi tạo Admin Client để tạo user
    const body = await req.json()
    const csvData = body.csvData

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      { auth: { autoRefreshToken: false, persistSession: false } }
    )

    // ==========================================
    // 4. LOGIC XỬ LÝ VÀ IMPORT CSV
    // ==========================================
    // Tách các dòng, hỗ trợ cả \r\n (Windows) và \n (Mac/Linux)
    const lines = csvData.split(/\r?\n/)
    if (lines.length <= 1) {
      throw new Error('File CSV trống hoặc chỉ có tiêu đề.')
    }

    let successCount = 0
    let errors: string[] =[]

    // Bắt đầu lặp từ dòng thứ 2 (index 1) vì dòng 1 là Headers
    for (let i = 1; i < lines.length; i++) {
      const line = lines[i].trim()
      if (!line) continue // Bỏ qua dòng trống

      // Tách cột bằng dấu phẩy (bỏ qua dấu phẩy nằm trong ngoặc kép)
      // Phù hợp với cấu trúc: employee_code, full_name, email, password, phone_number, role, is_active
      const columns = line.split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/).map(col => col.replace(/^"|"$/g, '').trim())

      // Map dữ liệu vào các biến
      const empCode = columns[0]
      const fullName = columns[1]
      const email = columns[2]
      const password = columns[3]
      const phone = columns[4]
      const role = columns[5] || 'worker'
      const isActive = (columns[6] || '').toLowerCase() === 'true'

      // Kiểm tra các trường bắt buộc
      if (!empCode || !fullName || !email || !password) {
        errors.push(`Dòng ${i + 1}: Thiếu thông tin bắt buộc (Mã NV, Tên, Email hoặc Mật khẩu).`)
        continue
      }

      try {
        // Bước 4.1: Tạo tài khoản bên Auth
        const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
          email: email,
          password: password,
          email_confirm: true, // Tự động xác nhận email
        })

        if (authError) throw authError

        const userId = authData.user.id

        // Bước 4.2: Lưu thông tin vào bảng profiles
        const { error: profileError } = await supabaseAdmin.from('profiles').insert({
          id: userId,
          employee_code: empCode,
          full_name: fullName,
          email: email,
          phone_number: phone,
          role: role,
          is_active: isActive,
        })

        // Nếu ghi vào profiles lỗi (ví dụ: Trùng Mã Nhân viên)
        if (profileError) {
          // Xóa tài khoản Auth vừa tạo để tránh rác database (Rollback)
          await supabaseAdmin.auth.admin.deleteUser(userId)
          throw profileError
        }

        successCount++
      } catch (err) {
        // Bắt lỗi từng dòng (Ví dụ: Email đã tồn tại, pass quá ngắn...)
        errors.push(`Dòng ${i + 1} (${email}): ${err.message}`)
      }
    }

    // 5. Trả kết quả về cho Flutter App
    let finalMessage = `Đã import thành công ${successCount} nhân viên.`
    if (errors.length > 0) {
      finalMessage += `\nCó ${errors.length} dòng bị lỗi. Hãy kiểm tra console/log.`
      console.log('--- LỖI IMPORT CSV ---')
      console.log(errors.join('\n'))
    }

    return new Response(JSON.stringify({ message: finalMessage, error_details: errors }), {
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