# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShifts::List, type: :operation do
  describe ".result" do
    context "with valid params" do
      it "is successful" do
        user = create(:user)
        create_list(:medical_shift, 3, user: user)

        result = described_class.result(
          page: nil,
          per_page: nil,
          payd: nil,
          month: nil,
          hospital_id: nil,
          user_id: user.id
        )

        expect(result.success?).to be true
      end

      it "returns medical_shifts ordered by created_at desc" do
        user = create(:user)
        today_medical_shift = create(:medical_shift, created_at: Time.zone.today, user: user)
        yesterday_medical_shift = create(:medical_shift, created_at: Time.zone.yesterday, user: user)
        tomorrow_medical_shift = create(:medical_shift, created_at: Time.zone.tomorrow, user: user)

        result = described_class.result(
          page: nil,
          per_page: nil,
          payd: nil,
          month: nil,
          hospital_id: nil,
          user_id: user.id
        )

        expect(result.medical_shifts).to eq [tomorrow_medical_shift, today_medical_shift, yesterday_medical_shift]
      end

      it "includes hospital" do
        user = create(:user)
        create(:medical_shift, user: user)

        result = described_class.result(
          page: nil,
          per_page: nil,
          payd: nil,
          month: nil,
          hospital_id: nil,
          user_id: user.id
        )

        expect(result.medical_shifts.first.association(:hospital).loaded?).to be true
      end

      context "when has pagination via page and per_page" do
        it "returns the medical_shifts paginated" do
          user = create(:user)
          create_list(:medical_shift, 5, user: user)

          result = described_class.result(
            page: "1",
            per_page: "3",
            payd: nil,
            month: nil,
            hospital_id: nil,
            user_id: user.id
          )

          expect(result.medical_shifts.count).to eq 3
        end
      end

      context "when there is the filter per month" do
        it "returns medical_shifts per month" do
          user = create(:user)
          february_medical_shift = create(:medical_shift, date: "2023-02-15", user: user)
          _september_medical_shift = create(:medical_shift, date: "2023-09-26", user: user)

          result = described_class.result(
            page: nil,
            per_page: nil,
            payd: nil,
            month: "2",
            hospital_id: nil,
            user_id: user.id
          )

          expect(result.medical_shifts).to eq [february_medical_shift]
        end
      end

      context "when there is the filter per hospital" do
        it "returns medical_shifts per hospital" do
          user = create(:user)
          hospital = create(:hospital)
          hospital_medical_shift = create(:medical_shift, hospital: hospital, user: user)
          _another_hospital_medical_shift = create(:medical_shift, user: user)

          result = described_class.result(
            page: nil,
            per_page: nil,
            payd: nil,
            month: nil,
            hospital_id: hospital.id.to_s,
            user_id: user.id
          )

          expect(result.medical_shifts).to eq [hospital_medical_shift]
        end
      end

      context "when there is the filter per payd" do
        it "returns paid medical_shifts" do
          user = create(:user)
          paid_medical_shifts = create_list(:medical_shift, 3, was_paid: true, user: user)
          _unpaid_medical_shifts = create_list(:medical_shift, 3, was_paid: false, user: user)

          result = described_class.result(
            page: nil,
            per_page: nil,
            payd: "true",
            month: nil,
            hospital_id: nil,
            user_id: user.id
          )

          expect(result.medical_shifts.to_a).to match_array(paid_medical_shifts)
        end

        it "returns unpaid medical_shifts" do
          user = create(:user)
          _paid_medical_shifts = create_list(:medical_shift, 3, was_paid: true, user: user)
          unpaid_medical_shifts = create_list(:medical_shift, 3, was_paid: false, user: user)

          result = described_class.result(
            page: nil,
            per_page: nil,
            payd: "false",
            month: nil,
            hospital_id: nil,
            user_id: user.id
          )

          expect(result.medical_shifts.to_a).to match_array(unpaid_medical_shifts)
        end
      end
    end
  end
end
