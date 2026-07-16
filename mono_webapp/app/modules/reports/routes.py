from flask import Blueprint, abort, render_template
from flask_login import current_user, login_required

from app.modules.reports import services

reports_bp = Blueprint("reports", __name__, url_prefix="/reports")


def _require_admin():
    if current_user.role != "admin":
        abort(403)


@reports_bp.route("/")
@login_required
def dashboard():
    _require_admin()

    course_stats = services.course_enrollment_stats()

    return render_template(
        "reports/dashboard.html",
        kpis=services.get_kpis(),
        top_courses=services.top_courses(course_stats),
        at_risk_courses=services.courses_at_risk(course_stats),
        instructor_workload=services.instructor_workload(course_stats),
        top_students=services.top_students(),
        inactive_students=services.students_without_enrollments(),
        monthly_trend=services.monthly_enrollment_trend(),
        cancellation_report=services.cancellation_rate_by_course(),
        cancellations_trend=services.cancellations_per_month(),
        time_to_cancel=services.avg_days_to_cancellation_by_course(),
    )
