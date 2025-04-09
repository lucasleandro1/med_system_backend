# frozen_string_literal: true

class EventProcedure < ApplicationRecord
  acts_as_paranoid

  has_enumeration_for :room_type, with: EventProcedures::RoomTypes, create_helpers: true
  has_enumeration_for :payment, with: EventProcedures::Payments, create_helpers: true

  monetize :total_amount

  belongs_to :cbhpm
  belongs_to :health_insurance
  belongs_to :hospital
  belongs_to :patient
  belongs_to :procedure
  belongs_to :user

  accepts_nested_attributes_for :patient
  accepts_nested_attributes_for :procedure
  accepts_nested_attributes_for :health_insurance

  scope :by_month, EventProcedures::ByMonthQuery
  scope :by_payd, EventProcedures::ByPaydQuery
  scope :by_year, EventProcedures::ByYearQuery
  scope :date_between, EventProcedures::ByDateBetween
  scope :by_hospital_name, EventProcedures::ByHospitalNameQuery
  scope :by_health_insurance_name, EventProcedures::ByHealthInsuranceNameQuery

  validates :date, presence: true
  validates :patient_service_number, presence: true
  validates :room_type, presence: true, if: -> { health_insurance? }
  validates :urgency, inclusion: [true, false], if: -> { health_insurance? }
  validates :payment, presence: true

  validate :custom_and_urgency_cannot_both_be_true

  private

  def custom_and_urgency_cannot_both_be_true
    return unless procedure&.custom && urgency

    errors.add(:base, "EventProcedure cannot have both custom and urgency as true")
  end
end
