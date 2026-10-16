namespace :finops do
  desc "SLA süresi (15 dk) dolan throttled ambarları güvenle askıya alır"
  task auto_govern: :environment do
    puts "[FinOps] AutoGovernorEngine çalıştırılıyor..."
    suspended = Finops::AutoGovernorEngine.run!
    puts "[FinOps] Tamamlandı. Otomatik askıya alınan ambar sayısı: #{suspended.count}"
    suspended.each do |wh|
      puts "  - #{wh.name} (Kota: #{wh.credit_quota}, Tüketim: #{wh.credits_used})"
    end
  end
end
