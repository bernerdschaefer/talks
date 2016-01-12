expect(page).to have_current_job

def have_current_job
  have_css(".job.current")
end
