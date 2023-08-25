class CommentsController < ApplicationController
  def create
    comment = @commentable.comments.build(comment_params.merge(user_id: current_user.id))
    if comment.save
      redirect_to @commentable, notice: t('controllers.common.notice_create', name: Comment.model_name.human)
    else
      # error表示用 : validatesにかかった場合の、errorsを持ったオブジェクト
      @comment = @commentable.comments.find { |comment| comment.id.nil? }

      # create失敗時にDBに未保存のデータが残っており、ビューでエラーが出るため、DBから引き直す
      @commentable.comments.reset
      render_show_template_of_commentable
    end
  end

  def edit
    @comment = @commentable.comments.find(params[:id])
    render file: "#{Rails.root}/public/403.html", layout: false, status: :forbidden if @comment.user_id != current_user.id
  end
  
  def update
    @comment = @commentable.comments.find(params[:id])
    if @comment.update(comment_params)
      redirect_to @commentable, notice: t('controllers.common.notice_update', name: Comment.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    comment = @commentable.comments.find(params[:id])
    if comment.destroy
      redirect_to @commentable, notice: t('controllers.common.notice_destroy', name: Comment.model_name.human)
    else
      render_show_template_of_commentable
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
