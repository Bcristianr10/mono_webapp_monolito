from app.database import db
from app.modules.courses.models import Course
from app.modules.enrollments.models import Enrollment, EnrollmentStatusHistory
from app.modules.users.models import User


def get_kpis() -> dict:
    users_by_role = dict(
        db.session.execute(
            db.select(User.role, db.func.count(User.id)).group_by(User.role)
        ).all()
    )

    courses_active = db.session.execute(
        db.select(db.func.count(Course.id)).filter_by(is_active=True)
    ).scalar_one()
    courses_inactive = db.session.execute(
        db.select(db.func.count(Course.id)).filter_by(is_active=False)
    ).scalar_one()

    enrollments_active = db.session.execute(
        db.select(db.func.count(Enrollment.id)).filter_by(status="active")
    ).scalar_one()
    enrollments_cancelled = db.session.execute(
        db.select(db.func.count(Enrollment.id)).filter_by(status="cancelled")
    ).scalar_one()

    capacity_active_courses = db.session.execute(
        db.select(db.func.coalesce(db.func.sum(Course.capacity), 0)).filter_by(is_active=True)
    ).scalar_one()

    utilization = (
        (enrollments_active / capacity_active_courses * 100) if capacity_active_courses else 0
    )

    return {
        "users_by_role": users_by_role,
        "total_users": sum(users_by_role.values()),
        "courses_active": courses_active,
        "courses_inactive": courses_inactive,
        "enrollments_active": enrollments_active,
        "enrollments_cancelled": enrollments_cancelled,
        "capacity_active_courses": capacity_active_courses,
        "utilization": round(utilization, 1),
    }


def course_enrollment_stats() -> list[dict]:
    """Cupo activo/ocupación de cada curso activo, base para varios reportes."""
    rows = db.session.execute(
        db.select(
            Course.id,
            Course.title,
            Course.capacity,
            Course.instructor_id,
            db.func.count(Enrollment.id),
        )
        .select_from(Course)
        .outerjoin(
            Enrollment,
            db.and_(Enrollment.course_id == Course.id, Enrollment.status == "active"),
        )
        .filter(Course.is_active == True)  # noqa: E712
        .group_by(Course.id)
    ).all()

    stats = []
    for course_id, title, capacity, instructor_id, active_count in rows:
        stats.append(
            {
                "id": course_id,
                "title": title,
                "capacity": capacity,
                "instructor_id": instructor_id,
                "active_count": active_count,
                "fill_rate": round((active_count / capacity * 100) if capacity else 0, 1),
            }
        )
    return stats


def top_courses(stats: list[dict], limit: int = 5) -> list[dict]:
    return sorted(stats, key=lambda c: c["active_count"], reverse=True)[:limit]


def courses_at_risk(stats: list[dict], threshold: float = 0.8) -> list[dict]:
    at_risk = [c for c in stats if c["capacity"] and c["active_count"] / c["capacity"] >= threshold]
    return sorted(at_risk, key=lambda c: c["fill_rate"], reverse=True)


def instructor_workload(stats: list[dict]) -> list[dict]:
    instructor_ids = {c["instructor_id"] for c in stats}
    if not instructor_ids:
        return []

    instructors = {
        u.id: u
        for u in db.session.execute(
            db.select(User).filter(User.id.in_(instructor_ids))
        ).scalars()
    }

    by_instructor: dict[int, list[dict]] = {}
    for c in stats:
        by_instructor.setdefault(c["instructor_id"], []).append(c)

    workload = []
    for instructor_id, courses in by_instructor.items():
        instructor = instructors.get(instructor_id)
        total_students = sum(c["active_count"] for c in courses)
        avg_fill_rate = sum(c["fill_rate"] for c in courses) / len(courses)
        workload.append(
            {
                "instructor_id": instructor_id,
                "instructor_name": instructor.full_name if instructor else "Desconocido",
                "course_count": len(courses),
                "total_students": total_students,
                "avg_fill_rate": round(avg_fill_rate, 1),
            }
        )

    return sorted(workload, key=lambda w: w["total_students"], reverse=True)


def top_students(limit: int = 5) -> list[dict]:
    rows = db.session.execute(
        db.select(User.id, User.full_name, User.email, db.func.count(Enrollment.id))
        .select_from(User)
        .join(Enrollment, db.and_(Enrollment.user_id == User.id, Enrollment.status == "active"))
        .filter(User.role == "student")
        .group_by(User.id)
        .order_by(db.func.count(Enrollment.id).desc())
        .limit(limit)
    ).all()

    return [
        {"id": uid, "full_name": full_name, "email": email, "active_enrollments": count}
        for uid, full_name, email, count in rows
    ]


def students_without_enrollments() -> list[User]:
    return db.session.execute(
        db.select(User)
        .filter(User.role == "student")
        .filter(
            ~User.id.in_(
                db.select(Enrollment.user_id).filter_by(status="active")
            )
        )
        .order_by(User.created_at.desc())
    ).scalars().all()


def monthly_enrollment_trend(months: int = 6) -> list[dict]:
    month_expr = db.func.to_char(Enrollment.enrolled_at, "YYYY-MM")
    rows = db.session.execute(
        db.select(month_expr, db.func.count(Enrollment.id))
        .filter(Enrollment.enrolled_at.isnot(None))
        .group_by(month_expr)
        .order_by(month_expr)
    ).all()

    recent = rows[-months:]
    max_count = max((count for _, count in recent), default=0)

    return [
        {
            "month": month,
            "count": count,
            "bar_width": round((count / max_count * 100) if max_count else 0),
        }
        for month, count in recent
    ]


def cancellation_rate_by_course(limit: int = 10) -> list[dict]:
    rows = db.session.execute(
        db.select(Enrollment.course_id, Enrollment.status, db.func.count(Enrollment.id)).group_by(
            Enrollment.course_id, Enrollment.status
        )
    ).all()

    by_course: dict[int, dict] = {}
    for course_id, status, count in rows:
        entry = by_course.setdefault(course_id, {"active": 0, "cancelled": 0})
        entry[status] = entry.get(status, 0) + count

    course_ids = [cid for cid, counts in by_course.items() if counts.get("cancelled", 0) > 0]
    if not course_ids:
        return []

    titles = {
        c.id: c.title
        for c in db.session.execute(
            db.select(Course).filter(Course.id.in_(course_ids))
        ).scalars()
    }

    report = []
    for course_id in course_ids:
        counts = by_course[course_id]
        total = counts.get("active", 0) + counts.get("cancelled", 0)
        report.append(
            {
                "course_id": course_id,
                "title": titles.get(course_id, "Curso eliminado"),
                "active": counts.get("active", 0),
                "cancelled": counts.get("cancelled", 0),
                "cancellation_rate": round((counts["cancelled"] / total * 100) if total else 0, 1),
            }
        )

    return sorted(report, key=lambda r: r["cancellation_rate"], reverse=True)[:limit]


def cancellations_per_month(months: int = 6) -> list[dict]:
    month_expr = db.func.to_char(EnrollmentStatusHistory.changed_at, "YYYY-MM")
    rows = db.session.execute(
        db.select(month_expr, db.func.count(EnrollmentStatusHistory.id))
        .filter(EnrollmentStatusHistory.status == "cancelled")
        .group_by(month_expr)
        .order_by(month_expr)
    ).all()

    recent = rows[-months:]
    max_count = max((count for _, count in recent), default=0)

    return [
        {
            "month": month,
            "count": count,
            "bar_width": round((count / max_count * 100) if max_count else 0),
        }
        for month, count in recent
    ]


def avg_days_to_cancellation_by_course(limit: int = 10, min_cancellations: int = 2) -> list[dict]:
    """Cursos donde los estudiantes cancelan más rápido: señal de posible problema de calidad."""
    seconds_to_cancel = db.func.extract(
        "epoch", EnrollmentStatusHistory.changed_at - Enrollment.enrolled_at
    )
    rows = db.session.execute(
        db.select(
            Enrollment.course_id,
            db.func.avg(seconds_to_cancel),
            db.func.count(EnrollmentStatusHistory.id),
        )
        .select_from(Enrollment)
        .join(EnrollmentStatusHistory, EnrollmentStatusHistory.enrollment_id == Enrollment.id)
        .filter(EnrollmentStatusHistory.status == "cancelled")
        .filter(Enrollment.enrolled_at.isnot(None))
        .group_by(Enrollment.course_id)
        .having(db.func.count(EnrollmentStatusHistory.id) >= min_cancellations)
    ).all()

    if not rows:
        return []

    course_ids = [course_id for course_id, _, _ in rows]
    titles = {
        c.id: c.title
        for c in db.session.execute(db.select(Course).filter(Course.id.in_(course_ids))).scalars()
    }

    report = [
        {
            "course_id": course_id,
            "title": titles.get(course_id, "Curso eliminado"),
            "avg_days_to_cancel": round(avg_seconds / 86400, 1),
            "cancellations": cancel_count,
        }
        for course_id, avg_seconds, cancel_count in rows
    ]

    return sorted(report, key=lambda r: r["avg_days_to_cancel"])[:limit]
