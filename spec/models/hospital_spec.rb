# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hospital do
  describe "associations" do
    it { is_expected.to have_many(:event_procedures).dependent(:destroy) }
    it { is_expected.to have_many(:medical_shifts).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:address) }

    context "when validating name and address uniqueness" do
      it "does not allow duplicate names and addresses" do
        create(:hospital, name: "nome hospital", address: "Barbalha- CE")
        new_hospital = build(:hospital, name: "nomE hospitAl", address: "Barbalha- Ce")

        expect(new_hospital).not_to be_valid
        expect(new_hospital.errors[:name]).to include("has already been taken")
        expect(new_hospital.errors[:address]).to include("has already been taken")
      end
    end
  end
end
