# == Schema Information
#
# Table name: parties
#
#  id         :integer          not null, primary key
#  host       :string(255)
#  location   :string(255)
#  number     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  time       :datetime
#

class Party < ActiveRecord::Base
  attr_accessible :host, :location, :number
end
