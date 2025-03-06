class FraudDetectionService
  # Detects potential fraudulent betting patterns for a user.
  # For demonstration, flags if any bet amount exceeds 50% of the user's balance.
  def self.detect(user)
    user.bets.any? { |bet| bet.amount.to_f > (user.balance.to_f * 0.5) }
  end

  # Flags potential fraudulent activity and returns a message.
  def self.flag(user)
    if detect(user)
      Rails.logger.warn("Fraudulent activity detected for user #{user.id}: Bet exceeds 50% of balance.")
      "Fraudulent activity detected for user #{user.id}"
    else
      "No anomalies detected for user #{user.id}"
    end
  end
end
