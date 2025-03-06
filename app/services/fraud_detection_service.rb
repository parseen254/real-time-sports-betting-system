class FraudDetectionService
  SUSPICIOUS_THRESHOLD = 0.95 # 95% win rate is suspicious
  MAX_BETS_PER_HOUR = 20
  MAX_AMOUNT_PER_HOUR = 10000
  UNUSUAL_ODDS_THRESHOLD = 10
  MAX_BALANCE_PERCENTAGE = 0.5 # 50% of balance

  def self.analyze_betting_patterns(user)
    new(user).analyze
  end

  def initialize(user)
    @user = user
    @recent_bets = user.bets.where('created_at > ?', 1.hour.ago)
  end

  def analyze
    results = []
    
    results << check_betting_frequency
    results << check_betting_amounts
    results << check_win_rate
    results << check_unusual_odds
    results << check_balance_percentage
    
    suspicious_patterns = results.compact
    
    if suspicious_patterns.any?
      log_suspicious_activity(suspicious_patterns)
      {
        fraud: true,
        message: suspicious_patterns.join(". "),
        severity: calculate_severity(suspicious_patterns.size)
      }
    else
      {
        fraud: false,
        message: "No suspicious patterns detected",
        severity: :low
      }
    end
  end

  private

  def check_betting_frequency
    if @recent_bets.count > MAX_BETS_PER_HOUR
      "Unusual betting frequency detected: #{@recent_bets.count} bets in the last hour"
    end
  end

  def check_betting_amounts
    total_amount = @recent_bets.sum(:amount)
    if total_amount > MAX_AMOUNT_PER_HOUR
      "Large betting volume detected: $#{total_amount} in the last hour"
    end
  end

  def check_win_rate
    total_bets = @user.total_bets
    return nil if total_bets < 10 # Need minimum sample size
    
    if @user.win_rate > (SUSPICIOUS_THRESHOLD * 100)
      "Unusually high win rate: #{@user.win_rate}%"
    end
  end

  def check_unusual_odds
    unusual_odds_bets = @recent_bets.where('odds > ?', UNUSUAL_ODDS_THRESHOLD)
    if unusual_odds_bets.exists?
      "Bets placed with unusually high odds"
    end
  end

  def check_balance_percentage
    @recent_bets.each do |bet|
      if bet.amount > (@user.balance * MAX_BALANCE_PERCENTAGE)
        return "Bet amount exceeds #{MAX_BALANCE_PERCENTAGE * 100}% of user balance"
      end
    end
    nil
  end

  def calculate_severity(pattern_count)
    case pattern_count
    when 1 then :low
    when 2 then :medium
    else :high
    end
  end

  def log_suspicious_activity(patterns)
    Rails.logger.warn(
      "Suspicious betting activity detected for user #{@user.id}: #{patterns.join('. ')}"
    )
  end
end
