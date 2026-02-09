# Chrome DevTools MCP + Remote UI (Docker)

Dự án này cung cấp một môi trường Chrome ổn định chạy trong Docker, được tích hợp sẵn MCP (Model Context Protocol) Server và giao diện điều khiển từ xa qua trình duyệt (noVNC).

## ✨ Tính năng

- **Chrome Headless/Headful**: Chạy Chrome trong container với Xvfb.
- **MCP Server (SSE)**: Expose các công cụ điều khiển Chrome cho AI Agents.
- **noVNC Interface**: Xem và tương tác trực tiếp với trình duyệt qua cổng 6080.
- **Easy Setup**: Khởi động nhanh chóng với Docker Compose.

---

## 🚀 Khởi động nhanh

1.  **Clone dự án và truy cập thư mục:**
    ```bash
    cd /home/chaos/Documents/chaos/chrome-mcp-project
    ```

2.  **Khởi động container:**
    ```bash
    docker compose up -d --build
    ```

---

## 🔗 Các liên kết quan trọng

| Dịch vụ | URL | Mô tả |
| :--- | :--- | :--- |
| **Giao diện Web (UI)** | `http://localhost:6080/vnc.html?autoconnect=true` | Xem Chrome đang chạy |
| **MCP SSE Endpoint** | `http://localhost:3100/sse` | Kết nối cho AI Client |

*Thay `localhost` bằng IP máy chủ nếu bạn đang triển khai từ xa.*

---

## ⚙️ Cấu hình MCP Client

Để sử dụng server này với Claude Desktop hoặc các ứng dụng hỗ trợ MCP khác, hãy thêm cấu hình sau:

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

---

## 🛠️ Tùy chỉnh (Environment Variables)

Chỉnh sửa file `.env` để thay đổi các thiết lập mặc định:

- `HOST_MCP_PORT`: Cổng cho MCP Server (mặc định: 3100).
- `HOST_UI_PORT`: Cổng cho noVNC UI (mặc định: 6080).
- `SCREEN_WIDTH` / `SCREEN_HEIGHT`: Độ phân giải màn hình của trình duyệt.
- `CHROME_START_URL`: Trang web mở khi khởi động.

---

## 🔍 Kiểm tra hoạt động

- **Logs**: `docker compose logs -f`
- **Health Check**:
  ```bash
  curl -I http://127.0.0.1:3100/sse
  ```
