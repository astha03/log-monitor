class Api::V1::LogsController < ApplicationController 
  def get_log
    validate_params

    log_viewer = LogViewer.new(
      filename: params[:filename], 
      num_lines: params[:n], 
      search_text: params[:filter]
    )

    @log = {
      filename: params[:filename],
      content: log_viewer.fetch_log
    }
  end

  private

  def validate_params
    ActionController::Parameters.action_on_unpermitted_parameters = :raise

    params.require(:filename)
    params.permit(:filename, :n, :filter, :commit)
  end
end
