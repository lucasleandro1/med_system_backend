# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShifts::List, type: :operation do
  describe ".result" do
    context "with valid params" do
      it "is successful" do
        user = create(:user)
        create_list(:medical_shift, 3, user: user)

        result = described_class.result(scope: MedicalShift.all, params: {})

        expect(result.success?).to be true
      end

      it "returns medical_shifts ordered by start_date desc" do
        user = create(:user)
        today_medical_shift = create(:medical_shift, start_date: Time.zone.today, user: user)
        yesterday_medical_shift = create(:medical_shift, start_date: Time.zone.yesterday, user: user)
        tomorrow_medical_shift = create(:medical_shift, start_date: Time.zone.tomorrow, user: user)

        result = described_class.result(scope: MedicalShift.all, params: {})

        expect(result.medical_shifts).to eq [tomorrow_medical_shift, today_medical_shift, yesterday_medical_shift]
      end

      context "when has pagination via page and per_page" do
        it "returns the medical_shifts paginated" do
          user = create(:user)
          create_list(:medical_shift, 5, user: user)

          result = described_class.result(
            scope: MedicalShift.all,
            params: { page: "1", per_page: "3" }
          )

          expect(result.medical_shifts.count).to eq 3
        end
      end

      context "when there is the filter per month" do
        it "returns medical_shifts per month" do
          user = create(:user)
          february_medical_shift = create(:medical_shift, start_date: "2023-02-15", user: user)
          _september_medical_shift = create(:medical_shift, start_date: "2023-09-26", user: user)

          result = described_class.result(scope: MedicalShift.all, params: { month: "2" })

          expect(result.medical_shifts).to eq [february_medical_shift]
        end
      end

      context "when there is the filter per hospital" do
        it "returns medical_shifts per hospital" do
          user = create(:user)
          hospital = create(:hospital)
          hospital_medical_shift = create(:medical_shift, hospital_name: hospital.name, user: user)
          _another_hospital_medical_shift = create(:medical_shift, user: user)

          result = described_class.result(
            scope: MedicalShift.all,
            params: { hospital_name: hospital.name }
          )

          expect(result.medical_shifts).to eq [hospital_medical_shift]
        end
      end

      context "when there is the filter per paid" do
        it "returns paid medical_shifts" do
          user = create(:user)
          paid_medical_shifts = create_list(:medical_shift, 3, paid: true, user: user)
          _unpaid_medical_shifts = create_list(:medical_shift, 3, paid: false, user: user)

          result = described_class.result(scope: MedicalShift.all, params: { paid: "true" })

          expect(result.medical_shifts.to_a).to match_array(paid_medical_shifts)
        end

        it "returns unpaid medical_shifts" do
          user = create(:user)
          _paid_medical_shifts = create_list(:medical_shift, 3, paid: true, user: user)
          unpaid_medical_shifts = create_list(:medical_shift, 3, paid: false, user: user)

          result = described_class.result(scope: MedicalShift.all, params: { paid: "false" })

          expect(result.medical_shifts.to_a).to match_array(unpaid_medical_shifts)
        end
      end

      context "when there is filter by year" do
        subject(:result) { described_class.result(scope: MedicalShift.all, params: { year: "2023" }) }

        let(:user) { create(:user) }
        let(:medical_shifts) { create_list(:medical_shift, 2, start_date: "2024-01-01", user: user) }

        before do
          medical_shifts
          MedicalShift.last.update(start_date: "2023-01-01")
        end

        it { expect(result.medical_shifts).to eq [MedicalShift.last] }
      end
    end
  end
end
