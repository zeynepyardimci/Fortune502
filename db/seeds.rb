# Seed data for Buzul FinOps platform

admin = User.find_or_create_by!(email: "admin@buzul.local") do |u|
  u.full_name = "Zeynep Yardımcı"
  u.role = "admin"
  u.password = "Buzul2026!"
  u.password_confirmation = "Buzul2026!"
end

finops_lead = User.find_or_create_by!(email: "finops@buzul.local") do |u|
  u.full_name = "Deniz Yılmaz"
  u.role = "manager"
  u.password = "Buzul2026!"
  u.password_confirmation = "Buzul2026!"
end

dept_data = Department.find_or_create_by!(cost_center_code: "CP-101") do |d|
  d.name = "Veri Platformu & Altyapı"
  d.owner = finops_lead
end

dept_mkt = Department.find_or_create_by!(cost_center_code: "CP-102") do |d|
  d.name = "Pazarlama Analitiği"
  d.owner = finops_lead
end

dept_ai = Department.find_or_create_by!(cost_center_code: "CP-103") do |d|
  d.name = "Yapay Zeka & Veri Bilimi"
  d.owner = admin
end

# 1. Normal Active Warehouse
wh1 = Warehouse.find_or_create_by!(name: "Core-ETL-Pipeline", department: dept_data) do |w|
  w.size = "medium"
  w.status = "active"
  w.credit_quota = 2500.0
  w.credits_used = 850.0
  w.warning_threshold_pct = 80
end

# 2. Warning Status Warehouse (%82 usage)
wh2 = Warehouse.find_or_create_by!(name: "Marketing-BI-Reporting", department: dept_mkt) do |w|
  w.size = "small"
  w.status = "warning"
  w.credit_quota = 1000.0
  w.credits_used = 820.0
  w.warning_threshold_pct = 80
end

# 3. Throttled Status Warehouse (%105 usage - 15 min SLA active)
wh3 = Warehouse.find_or_create_by!(name: "DeepLearning-Model-Training", department: dept_ai) do |w|
  w.size = "large"
  w.status = "throttled"
  w.credit_quota = 2000.0
  w.credits_used = 2120.0
  w.warning_threshold_pct = 80
  w.sla_target_at = 12.minutes.from_now
end

# 4. Suspended Status Warehouse (Auto-governed)
wh4 = Warehouse.find_or_create_by!(name: "Legacy-AdHoc-Analytics", department: dept_data) do |w|
  w.size = "x-small"
  w.status = "suspended"
  w.credit_quota = 500.0
  w.credits_used = 540.0
  w.warning_threshold_pct = 80
  w.sla_target_at = nil
end

# Audit logs
StatusEvent.find_or_create_by!(warehouse: wh3, from_status: "warning", to_status: "throttled") do |e|
  e.reason = "Kota %100 aşıldı - 15 dakikalık SLA onay penceresi başlatıldı"
  e.triggered_by = admin
end

StatusEvent.find_or_create_by!(warehouse: wh4, from_status: "throttled", to_status: "suspended") do |e|
  e.reason = "15 dk SLA onay penceresi zaman aşımına uğradı (Auto-Governor Engine)"
  e.triggered_by = nil
end

puts "Buzul örnek verileri (Seed) başarıyla yüklendi!"
