module Api::V1

class ProcurementsController < Api::ApiController
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
end

end
