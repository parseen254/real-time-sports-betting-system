class FraudDetectionService
  # Detects suspicious betting patterns for a given user.
  # For this example, if a user places more than 5 bets with an amount greater than the threshold within the last hour,
  # it flags the user for potential fraud.
  def self.detect_fraud(user)
    threshold = 500.0
    recent_bets = user.bets.where("created_at > ?", 1.hour.ago)
    high_value_bets = recent_bets.select { |bet| bet.amount.to_f > threshold }
    
    if high_value_bets.count > 5
      { fraud: true, message: "Suspicious betting pattern detected: #{high_value_bets.count} high-value bets in the past hour." }
    else
      { fraud: false, message: "No fraudulent activity detected." }
    end
  end
  
  # Optionally, you could add more sophisticated analysis using statistical methods.
  def self.analyze_betting_patterns(user)
    # Placeholder for future detailed anomaly detection implementation.
    detect_fraud(user)
  end
end
