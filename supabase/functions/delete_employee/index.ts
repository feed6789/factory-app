// File: supabase/functions/delete-employee/index.ts
// *** PHIÊN BẢN ĐÃ SỬA LỖI CORS ***

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// ĐỊNH NGHĨA CÁC HEADER CHO PHÉP CORS
const corsHeaders = {
  'Access-Control-Allow-Origin': '*', // Cho phép mọi nguồn, hoặc 'http://localhost:53497' để test
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // BƯỚC QUAN TRỌNG: TRẢ LỜI YÊU CẦU "THĂM DÒ" (OPTIONS)
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { user_id } = await req.json()
    if (!user_id) throw new Error('User ID is required')

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Dùng quyền admin để xóa user khỏi hệ thống Auth
    const { error: authError } = await supabaseAdmin.auth.admin.deleteUser(user_id)

    if (authError && authError.message !== 'User not found') {
      // Nếu có lỗi khi xóa Auth (mà không phải là do user không tồn tại) thì báo lỗi
      throw authError
    }
    
    // Nếu xóa Auth thành công (hoặc user vốn không có trong Auth),
    // và bạn đã thiết lập ON DELETE CASCADE trong DB, thì mọi thứ đã xong.
    
    return new Response(JSON.stringify({ message: 'User deleted successfully' }), {
      status: 200,
      // THÊM HEADER VÀO RESPONSE THÀNH CÔNG
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      // THÊM HEADER VÀO RESPONSE LỖI
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})