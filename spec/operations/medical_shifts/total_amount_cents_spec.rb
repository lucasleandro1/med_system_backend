# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShifts::TotalAmountCents, type: :operation do
  describe ".result" do
    it "is successful" do
      user = create(:user)
      medical_shift = create(:medical_shift, amount_cents: 1000, payd: true, user:, start_date: "25/02/2023")

      expect(described_class.call(medical_shifts: [medical_shift])).to be_success
    end

    it "returns the total, payd and unpaid amount_cents of money" do
      user = create(:user)
      medical_shift = create(:medical_shift, amount_cents: 1000, payd: true, user:, start_date: "25/02/2023")
      _medical_shift2 = create(:medical_shift, amount_cents: 1000, payd: true, user:, start_date: "25/03/2023")
      payd_medical_shift = create(:medical_shift, amount_cents: 2000, payd: true, user:, start_date: "25/02/2023")
      _payd_medical_shift2 = create(:medical_shift, amount_cents: 2000, payd: true, user:, start_date: "25/03/2023")
      unpaid_medical_shift = create(:medical_shift, amount_cents: 1500, payd: false, user:, start_date: "25/02/2023")
      _unpaid_medical_shift2 = create(:medical_shift, amount_cents: 1500, payd: false, user:, start_date: "25/03/2023")

      result = described_class.call(
        medical_shifts:
                [
                  medical_shift,
                  payd_medical_shift,
                  unpaid_medical_shift
                ]
      )

      expect(result.total).to eq("R$45.00")
      expect(result.payd).to eq("R$30.00")
      expect(result.unpaid).to eq("R$15.00")
    end
  end
end
