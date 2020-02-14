class AdHocReportsController < ApplicationController

  before_action :authenticate_user!

  C_CLASS_NAME = "AdHocReportsController"

  def new
    authorize AdHocReport
    @item = AdHocReport.new
    @files = Dir.glob(Rails.root.join("public","upload") + "*.yaml")
  end

  def index
    authorize AdHocReport
    @items = AdHocReport.all
  end

  def create
    authorize AdHocReport
    report = AdHocReport.create_report(the_params)
    if report.errors.blank?
      AuditTrail.create_event(current_user, "Ad-hoc report '#{report.label}' created.")
      flash[:success] = "Report was successfully created."
      redirect_to ad_hoc_reports_path
    else
      flash[:error] = "#{report.errors.full_messages.to_sentence}."
      redirect_to new_ad_hoc_report_path
    end
  end  

  def run_start
    authorize AdHocReport
    @report = AdHocReport.find(params[:id])
    @columns = @report.columns
    @report.run(check_query_params) # Protect against dodgy URIs in the params
    render "results"
  end

  def run_progress
    authorize AdHocReport
    report = AdHocReport.find(params[:id])
    render json: { running: report.running? }
  end

  def run_results
    authorize AdHocReport
    report = AdHocReport.find(params[:id])
    results = AdHocReportFiles.read(report.results_file)
    render json: results
  end

  def results
    authorize AdHocReport
    @report = AdHocReport.find(params[:id])
    @columns = @report.columns
  end

  def destroy
    authorize AdHocReport
    report = AdHocReport.find(params[:id])
    report.destroy_report
    AuditTrail.delete_event(current_user, "Ad-hoc report '#{report.label}' deleted.")
    redirect_to request.referer
  end

  def export_csv
    authorize AdHocReport
    report = AdHocReport.find(params[:id])
    filename = AdHocReportFiles.report_csv_filename(report.label)
    send_data report.to_csv, filename: filename, :type => 'text/csv; charset=utf-8; header=present', disposition: "attachment"
  end

private

  def the_params
    params.require(:ad_hoc_report).permit(:files => [])
  end

  def query_params
    params.require(:ad_hoc_report).permit(:query_params => [])
  end

  def check_query_params
    params = query_params
    params[:query_params].each{|x| Errors.application_error(self.class.name, __method__.to_s, "Possible threat from bad id detected #{x}.") unless Uri.safe_id?(x)}
    params[:query_params]
  end

end