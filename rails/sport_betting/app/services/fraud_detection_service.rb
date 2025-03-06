class FraudDetectionService
  def self.detect_fraud(user)
    threshold = 500.0
    recent_bets = user.bets.where("created_at > ?", 1.hour.ago)
    high_value_bets = recent_bets.select { |bet| bet.amount.to_f > threshold }

    if high_value_bets.count > 5
      return { fraud: true, message: "Suspicious betting pattern detected: #{high_value_bets.count} high-value bets in the past hour." }
    else
      return { fraud: false, message: "No fraudulent activity detected." }
    end
  end

  def self.analyze_betting_patterns(user)
    detect_fraud(user)
  end
end
