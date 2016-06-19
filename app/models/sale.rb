class Sale < ActiveRecord::Base
  before_create :populate_guid

  belongs_to  :book

  private
  #SecureRandom generate a GUID for every sale
  def populate_guid
    self.guid = SecureRandom.uuid()
  end
end
