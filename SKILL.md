---
name: Chrome MCP Docker Control
description: Hướng dẫn cách điều khiển và quản lý Chrome MCP Server chạy trong môi trường Docker. Cung cấp khả năng duyệt web có giao diện (noVNC) và endpoint MCP cho các AI Agent.
---

# Chrome MCP Docker Skill

Skill này giúp người dùng khởi chạy và kết nối với một thực thể Chrome được container hóa, cho phép AI thực hiện các thao tác trên trình duyệt và người dùng có thể quan sát trực tiếp.

## 1. Khởi động Container

Di chuyển vào thư mục dự án và chạy Docker Compose:

```bash
cd /home/chaos/Documents/chaos/chrome-mcp-project
docker compose up -d --build
```

## 2. Thông tin Kết nối (Endpoints)

Sau khi khởi chạy, hệ thống cung cấp các điểm truy cập sau:

- **Giao diện người dùng (noVNC):** `http://localhost:6080/vnc.html?autoconnect=true&resize=scale`
- **MCP Server (SSE):** `http://localhost:3100/sse`

*Lưu ý: Nếu chạy trên máy chủ từ xa, hãy thay `localhost` bằng IP của máy chủ.*

## 3. Cấu hình cho AI Client

Để tích hợp vào các công cụ như Claude Desktop hoặc các ứng dụng hỗ trợ MCP, sử dụng cấu hình sau (có trong file `mcp.config`):

```json
{
  "mcpServers": {
    "chrome-devtools-docker": {
      "transport": "sse",
      "url": "http://127.0.0.1:3100/sse"
    }
  }
}
```

## 4. Các lệnh quản lý nhanh

- **Kiểm tra trạng thái:** `docker compose ps`
- **Xem logs thời gian thực:** `docker compose logs -f`
- **Dừng dịch vụ:** `docker compose down`
- **Kiểm tra kết nối MCP:**
  ```bash
  curl -sS "http://127.0.0.1:3100/sse" --max-time 2
  ```

## 5. Cấu hình Môi trường

Bạn có thể thay đổi các tham số như độ phân giải, cổng kết nối trong file `.env`. Sau khi chỉnh sửa, hãy khởi động lại container để áp dụng.
