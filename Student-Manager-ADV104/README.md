# Student Manager WS101 — V4

Plain PHP 8.1+, HTML, CSS, vanilla JavaScript, MySQL/MariaDB. No Laravel, React, Composer or npm. Designed for the WS101 guide; your team should understand and test all code before submission.

## Upgrade your existing V3 installation (recommended)

1. Export a full SQL backup in phpMyAdmin and back up the old website folder. Stop using V3 (or earlier) after upgrading: old grade editors do not enforce V4 submission locks.
2. In phpMyAdmin, select `student_management_ws101` and import **`database/upgrade_v4.sql`**. The script adds the new schema and updates the view. It does not delete or overwrite existing grades, accounts or enrollments. DDL commits independently, so back up first. If coming from V1 or V2, apply the previous missing upgrade scripts in order before V4.
3. Optional: import `database/term_demo_v4.sql` if you want example terms and units on the known fictional V3 demo classes. It creates AY 2026-2027 first and second semesters and moves known demo offerings from the historical term to first semester, setting only unknown units to 3. Do not use it on real records; it is an illustrative policy, not official HCDC curriculum. Other existing classes retain the historical term and unknown units until set by an administrator. Second semester starts empty.
4. Extract `Student-Manager-WS101-V4` into your XAMPP `htdocs` folder. Preserve your custom `config/database.php` settings. Start Apache and MySQL, and visit `http://localhost/Student-Manager-WS101-V4/`. Use the same accounts as V3. Do not continue using the old application against the upgraded database.

## Fresh installation only

Import `database/student_management_ws101.sql` into a NEW empty database (creates `student_management_ws101` and includes V4 schema and demo accounts). Optional on a fresh database: import `database/HCDC_WS101_sample_data.sql`, then `database/curriculum_demo_v3.sql`, then `database/term_demo_v4.sql`. Do not reimport old sample scripts into a populated V4 database with repeated subject codes across different terms. Configure `config/database.php` (defaults localhost/127.0.0.1, port 3306, root, blank password). Open the V4 folder URL. Demo login: admin / AdminDemo!2026; teacher / TeacherDemo!2026; student / StudentDemo!2026. Select the correct role. Local testing only: change demo passwords before shared use.

## Academic terms and classes

- Admin > Academic terms: create a consecutive academic year such as 2026-2027 and choose first semester, second semester or summer.
- Admin > Classes: choose the term, assign a teacher, enter subject units, code, title and schedule. Existing unassigned historical classes can be assigned their verified term and units. Existing enrolled classes with known terms or units are protected against historical changes. Reuse the same exact subject code when creating a new offering in a later term; each code is unique within a term. Up to three assignments per teacher per term, with existing overloads visible for review.
- Admin > Curriculum: map each stable subject code once to a course/year. Future offerings with the same code inherit the mapping. Choose the original mapped class for prerequisites. The curriculum does not have separate semester rules: actual offerings in the chosen term determine availability.
- Staff > Enrollments: find the student, select curriculum year and academic term, and choose eligible offerings. Earlier terms and imported historical grades can satisfy prerequisites. Already taken/enrolled subject codes remain blocked (repeat enrollment/retakes are not implemented). Staff may view grade summaries, not assessment editing or details.
- Teacher > Classes: responsive cards grouped by term, subject units, schedule, enrolled count, roster link, and submission count in the roster. Filter by term. Teachers can access only their assigned classes.

## Individual assessments and grade submission

Teacher > Grades: search by student, term or assigned class, then open a student and grading period. Add individual exam and quiz/activity rows (title, earned points, maximum points; up to 30 per category per student and period). Category percentage = sum earned / sum maximum x 100, rounded to two decimals. Enter the remaining project, attendance and participation percentages (0–100). The PHP server calculates the period grade with existing demo weights: exams 40%, quizzes/activities 20%, projects 25%, attendance 10%, participation 5%. Each period is weighted equally in the overall grade; all three must exist before overall is calculated. No official HCDC grading policy was supplied.

Save draft, then review and submit the saved period. Submission locks **that student's period**, not the entire class. Unsaved changes are not submitted. Locked grades and their raw marks cannot be changed or deleted through the V4 teacher editor. Admin can reopen a locked period in Grades > subject detail, giving a reason; only the assigned teacher can then edit and resubmit. Every save, submission, reopening and deletion is audited. Staff remain read-only; students see their own breakdown including individual scores. Drafts remain visible and clearly labeled to preserve V3 visibility; they are not a publication gate. Existing V3 period scores are preserved without fabricating raw assessments. Teachers can submit those saved scores as-is or enter actual raw marks to revise them. Existing legacy scores are retained and labeled.

Student > Grades: choose a named term to see a unit-weighted percentage average. It uses saved overall grades with known units only; coverage is shown, and incomplete subjects/unknown units are excluded. Not official HCDC GWA. Admin CSV includes academic term, units and number of locked periods. No class-wide assessment templates, repeat enrollments, or grade transmutation are added in this release.

## Verification

Run `php tests/grading_test.php`, `php tests/academic_test.php`, `php tests/assessments_test.php` and check `docs/V4_TEST_CASES.md`. PHP syntax, pure logic and JavaScript syntax were checked in the development environment. Live MySQL/MariaDB and authenticated browser workflows still need local testing; do not record them as passing before testing. The migration was reviewed but could not be executed on a live database here. See `docs/README_V3_HISTORICAL.md` for original data decisions and previous version documentation, not current installation instructions.
