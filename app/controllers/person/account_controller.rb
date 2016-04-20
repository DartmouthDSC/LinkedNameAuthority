class Person::AccountController < CrudController
  # GET /person/:person_id/orcid
  # 404 error if there is not an ORCID present.
  def orcid
    @account = search_for_orcid(params[:person_id])

    respond_to do |format|
      format.jsonld { render :orcid, content_type: 'application/ld+json' }
    end
  end
end
