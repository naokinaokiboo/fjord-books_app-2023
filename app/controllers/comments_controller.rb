# frozen_string_literal: true

class CommentsController < ApplicationController
  def create
    comment = @commentable.comments.build(comment_params.merge(user_id: current_user.id))
    if comment.save
      redirect_to @commentable, notice: t('controllers.common.notice_create', name: Comment.model_name.human)
    else
      # error表示用 : validatesにかかった場合の、errorsを持ったオブジェクト
      @comment = comment

      # create失敗時にDBに未保存のデータが残っており、ビューでエラーが出るため、DBから引き直す
      @commentable.comments.reset
      render_show_template_of_commentable
    end
  end

  def edit
    render_403_page unless request_from_author?
  end

  def update
    render_403_page and return unless request_from_author?

    if @comment.update(comment_params)
      redirect_to @commentable, notice: t('controllers.common.notice_update', name: Comment.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    render_403_page and return unless request_from_author?

    if @comment.destroy
      redirect_to @commentable, notice: t('controllers.common.notice_destroy', name: Comment.model_name.human)
    else
      render_show_template_of_commentable
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end

  def request_from_author?
    @comment = @commentable.comments.find(params[:id])
    @comment.user_id == current_user.id
  end
end
