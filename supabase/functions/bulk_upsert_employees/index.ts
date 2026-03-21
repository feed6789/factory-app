import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Lưu ý: Việc import hàng loạt này chỉ tạo/cập nhật dữ liệu trong bảng 'profiles'.
// Nó không tạo tài khoản đăng nhập (auth users). Admin sẽ cần gửi lời mời
// hoặc đặt mật khẩu ban đầu cho các user mới sau khi import thành công.

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { csvData } = await req.json()
    if (!csvData) throw new Error("No CSV data provided.")

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const rows = csvData.trim().split('\n')
    const headers = rows.shift().trim().split(',')

    const employeesToUpsert = rows.map(rowStr => {
      const values = rowStr.trim().split(',')
      const employee = {}
      headers.forEach((header, index) => {
        employee[header.trim()] = values[index] ? values[index].trim() : null
      })
      // Chuyển đổi is_active từ chuỗi "true"/"false" sang boolean
      if (employee.is_active) {
          employee.is_active = employee.is_active.toLowerCase() === 'true'
      }
      return employee
    })

    // Dùng upsert để tự động tạo mới hoặc cập nhật nếu trùng 'employee_code'
    const { data, error } = await supabaseAdmin
      .from('profiles')
      .upsert(employeesToUpsert, { onConflict: 'employee_code' })
      .select()

    if (error) throw error

    return new Response(JSON.stringify({ 
      message: `Success! Processed ${data.length} records.`,
      data: data 
    }), {
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