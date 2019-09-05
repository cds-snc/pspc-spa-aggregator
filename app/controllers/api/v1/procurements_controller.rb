module Api::V1

class ProcurementsController < ApplicationController
  def index
    # TODO(dan.sinclair): This finds a random 25 elements, probably not what
    #  is desired in the future.
    @procurements = Procurement.order("RANDOM()").includes(
        :trade_agreements, :items, :recurrences, contact: [
          :languages, :procuring_entity]).first(25)
    render jbuilder: @procurements
  end

  def show
    @procurement = Procurement.find(params[:id])
    render jbuilder: @procurement
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
    render :index, jbuilder: @procurements
  end
end

end
