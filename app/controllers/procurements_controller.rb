class ProcurementsController < ApplicationController
  def index
    # TODO(dan.sinclair): Artificially limited to 25 random responses.
    @procurements = Procurement.order("RANDOM()").includes(
      :trade_agreements, :items, :recurrences, contact: [
        :languages, :procuring_entity]).first(25)
  end

  def show
    @procurement = Procurement.find(params[:id])
  end

  def search
    @procurements = []
    # TODO(dan.sinclair): Artificially limited to 25 responses.
    results = PgSearch.multisearch(params[:q]).first(25)
    results.each do |res|
      if res.searchable_type == "Procurement"
        @procurements << res.searchable
      elsif res.searchable_type == "ProcurementItem" ||
          res.searchable_type == "ProcurementTradeAgreement"
        @procurements << res.searchable.procurement
      else
        @procurements << res.searchable.procurements
      end
    end

    @procurements = @procurements.flatten.uniq
    render :index
  end
end
