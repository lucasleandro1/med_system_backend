# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShifts::Create, type: :operation do
  describe ".result" do
    context "with valid attributes" do
      it "is successful" do
        user = create(:user)
        attributes = {
          hospital_name: create(:hospital).name,
          workload: MedicalShifts::Workloads::SIX,
          start_date: "2024-01-29",
          start_hour: "10:51:23",
          amount_cents: 1,
          paid: false
        }

        result = described_class.result(attributes: attributes, user_id: user.id)

        expect(result.success?).to be true
      end

      it "creates a new medical shift" do
        user = create(:user)
        attributes = {
          hospital_name: create(:hospital).name,
          workload: MedicalShifts::Workloads::SIX,
          start_date: "2024-01-29",
          start_hour: "10:51:23",
          amount_cents: 1,
          paid: false
        }
        result = described_class.result(attributes: attributes, user_id: user.id)

        expect(result.medical_shift).to be_persisted
      end
    end

    context "with invalid attributes" do
      it "fails" do
        user = create(:user)
        attributes = { amount_cents: 1, paid: false }

        result = described_class.result(attributes: attributes, user_id: user.id)

        expect(result).to be_failure
      end

      it "does not create a new medical shift" do
        user = create(:user)
        attributes = { amount_cents: 1, paid: false }

        result = described_class.result(attributes: attributes, user_id: user.id)

        expect(result.medical_shift).not_to be_persisted
        expect(result.medical_shift).not_to be_valid
      end

      it "returns an error" do
        user = create(:user)
        attributes = { amount_cents: 1, paid: false }

        result = described_class.result(attributes: attributes, user_id: user.id)

        expect(result.error).to eq(:invalid_record)
        expect(result.medical_shift.errors.full_messages).to eq(
          [
            "Workload can't be blank",
            "Start date can't be blank",
            "Start hour can't be blank"
          ]
        )
      end
    end
  end
end
