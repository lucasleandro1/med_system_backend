# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::SumPaydAmountQuery do
  it "returns the sum payd of total_amount_cents" do
    user = create(:user)
    procedure_1000 = create(:procedure, amount_cents: 1000)
    procedure_1500 = create(:procedure, amount_cents: 1500)

    _event_procedure = create(:event_procedure, procedure: procedure_1000, payd_at: Time.zone.today, user: user)
    _payd_event_procedure = create(:event_procedure, procedure: procedure_1000, payd_at: Time.zone.today, user: user)
    _unpaid_event_procedure = create(:event_procedure, procedure: procedure_1500, payd_at: nil, user: user)

    sum_payd_amount_query = described_class.call(user_id: user.id)

    expect(sum_payd_amount_query).to eq(2000)
  end
end
