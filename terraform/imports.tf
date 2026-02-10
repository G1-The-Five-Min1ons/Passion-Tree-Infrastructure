# ─── Import existing resources into Terraform state ───
# Cloudflare DNS records ยังอยู่ (ไม่ได้ถูกลบตอน cleanup Azure)
# ต้อง import เข้า state เพื่อไม่ให้ Terraform พยายามสร้างซ้ำ
# หลัง apply สำเร็จครั้งแรก สามารถลบ import blocks ออกได้

# import {
#   to = cloudflare_record.backend_cname
#   id = "${var.cloudflare_zone_id}/a62c4d6c74508f5532b99a898b05483a"
# }

# import {
#   to = cloudflare_record.domain_verification
#   id = "${var.cloudflare_zone_id}/73c6e9662834d08a1f52ab7423ef106b"
# }
