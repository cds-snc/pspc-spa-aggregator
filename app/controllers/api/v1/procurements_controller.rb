module Api::V1

class ProcurementsController < ApplicationController
  def index
    @procurements = Procurement.all.includes(
        :trade_agreements, :items, :recurrences, contact: [
          :languages, :procuring_entity])
    render jbuilder: @procurements
  end

  def show
    @procurement = Procurement.find(params[:id])
    render jbuilder: @procurement
  end

  def search
    @procurements = []
    results = PgSearch.multisearch(params[:q])
    results.each do |res|
      if res.searchable.is_a?(Procurement)
        @procurements << res.searchable
      elsif res.searchable.is_a?(ProcurementItem) ||
          res.searchable.is_a?(ProcurementTradeAgreement)
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
