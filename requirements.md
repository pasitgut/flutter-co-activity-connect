# Group Creation and Management

## Create Group

- ผู้ใช้สร้างกลุ่ม โดยระบุ ชื่อกลุ่ม คำอธิบาย รูปภาพเกี่ยวกับกิจกรรม ประเภทกิจกรรม แท็ก เงื่อนไขการเข้าร่วม จำนวนสมาชิกสูงสุด

## Group Management

- เจ้าของกลุ่ม สามารถ เพิ่ม ลบ สมาชิกได้ ตั้ง admin เพิ่มได้ แก้ไขกลุ่มให้เป็น private/public ได้
- ออกจากกลุ่มได้

## Join Group

- ขอเข้าร่วมกลุ่มได้ เมื่อกลุ่มเป็น private
- แสดงสมาชิกกลุ่มทั้งหมด

# Matching & Discovery

## Search & Filter

- ค้นหากลุ่มด้วย keyword, filter, tag, type,

# Communication & Collaboration

## In-group chat

- Real-time Chat (Firebase chat or WebSocket)
- Support message, image, pdf
- Support pinned message

## Event-Scheduling

- Create event in group ex. นัดติวสอบวันศุกร์
- Integration with Google Calendar
- RSVP (ตอบรับ/ปฏิเสธ) และแสดงผู้เข้าร่วม
- UI: Calendar

## Notifications

- Push Notification (มีบุคคลเข้าร่วมกลุ่ม, ข้อความใหม่, event updates)
- ตั้งค่าการแจ้งเตือน

private + not join = requested to join
private + join = group chat + member list
public + not join = requested to joing + member list
public + join = group chat + member list

flutter build apk --target-platform android-arm,android-arm64,android-x64
