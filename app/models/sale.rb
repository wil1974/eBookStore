class Sale < ActiveRecord::Base
  before_create :populate_guid

  belongs_to  :book

  #include statemachine and define the states needed
  include AASM
    aasm column: 'state' do
      state :pending, initial: true
      state :processing
      state :finished
      state :errored

      #define transitions between states by tracking events
      #On the event that the charge_card is called,
      # we can update the event :process  from pending to processing.
      event :process, after: :charge_card do
        transitions from: :pending, to: :processing
      end

      #if the payment is processed, we want to transit
      #the state from :processing to :finished.
      event :finish do
        transitions from: :processing, to: :finished
      end

      #anything else the event should be :fail,
      # and we would go from :processing to :errored.
      event :fail do
        transitions from: :processing, to: :errored
      end
    end

  #move charge_card code from transactions_controller into a method here
  #reason is skinny controller , fat model paradigm
  def charge_card
    begin
      save!
      charge = Stripe::Charge.create(
        amount: self.amount,
        currency: "usd",
        card: self.stripe_token,
        description: self.guid
        )
      self.update(stripe_id: charge.id)
      self.finish!
    rescue Stripe::StripeError => e
      self.update_attributes(error: e.message)
      self.fail!
    end
  end

  private
  #SecureRandom generate a GUID for every sale
  def populate_guid
    self.guid = SecureRandom.uuid()
  end
end
