class Reports::CommentsController < CommentsController
  before_action :set_commentable

  private

  def set_commentable
    @commentable = Report.find(params[:report_id])
  end

  def render_show_template_of_commentable
    # create失敗時にDBに未保存のデータが残っており、ビューでエラーが出るため、DBから引き直す
    @commentable.comments.reset

    @report = @commentable
    render template: 'reports/show', status: :unprocessable_entity
  end
end
