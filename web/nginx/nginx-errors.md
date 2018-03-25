# nginx 400

发送HTTP请求时,发送的请求头(Request Header)太大导致

client_header_buffer_size    128k;
large_client_header_buffers  4  128k;

# 403 

访问权限不对

# 404
根目录指定不对