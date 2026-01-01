# Generated manually
# Note: The feedback table already exists from the old feedback app.
# This migration registers the model with Django's ORM and adds missing indexes.

from django.db import migrations, models
import django.db.models.deletion
import django.core.validators


def add_indexes_if_not_exists(apps, schema_editor):
    """
    Add indexes only if they don't exist.
    The table already exists, so we just need to add indexes.
    """
    with schema_editor.connection.cursor() as cursor:
        indexes_to_add = [
            ('feedback_worker_created_idx', 'worker_id, created_at'),
            ('feedback_citizen_created_idx', 'citizen_id, created_at'),
            ('feedback_rating_idx', 'rating'),
            ('feedback_created_at_idx', 'created_at'),
        ]
        
        for index_name, fields in indexes_to_add:
            # Check if index exists
            cursor.execute("""
                SELECT EXISTS (
                    SELECT FROM pg_indexes 
                    WHERE schemaname = 'public' 
                    AND indexname = %s
                );
            """, [index_name])
            index_exists = cursor.fetchone()[0]
            
            if not index_exists:
                # Create index
                try:
                    cursor.execute(f"""
                        CREATE INDEX {index_name} ON feedback ({fields});
                    """)
                except Exception as e:
                    # Index might already exist or table structure might be different
                    print(f"Warning: Could not create index {index_name}: {e}")


def reverse_migration(apps, schema_editor):
    """
    Reverse migration - do nothing since table may be used by other apps
    """
    pass


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0001_initial'),
        ('reports', '0001_initial'),
        ('gamification', '0002_workermonthlystats'),
    ]

    operations = [
        # Register model state without creating table (table already exists)
        migrations.SeparateDatabaseAndState(
            database_operations=[],  # Don't create table - it already exists
            state_operations=[
                migrations.CreateModel(
                    name='Feedback',
                    fields=[
                        ('feedback_id', models.BigAutoField(primary_key=True, serialize=False)),
                        ('rating', models.PositiveSmallIntegerField(help_text='Star rating (1-5)', validators=[django.core.validators.MinValueValidator(1), django.core.validators.MaxValueValidator(5)])),
                        ('comment', models.TextField(blank=True, help_text='Optional written feedback', null=True)),
                        ('created_at', models.DateTimeField(auto_now_add=True, db_index=True)),
                        ('updated_at', models.DateTimeField(auto_now=True)),
                        ('citizen', models.ForeignKey(db_column='citizen_id', help_text='ID of the rating provider', limit_choices_to={'role': 'Citizen'}, on_delete=django.db.models.deletion.CASCADE, related_name='given_feedbacks', to='accounts.account')),
                        ('report', models.OneToOneField(db_column='report_id', help_text='Link to a specific completed job', on_delete=django.db.models.deletion.CASCADE, related_name='feedback', to='reports.report', unique=True)),
                        ('worker', models.ForeignKey(db_column='worker_id', help_text='Staff being rated', limit_choices_to={'role': 'Worker'}, on_delete=django.db.models.deletion.CASCADE, related_name='received_feedbacks', to='accounts.account')),
                    ],
                    options={
                        'verbose_name': 'Feedback',
                        'verbose_name_plural': 'Feedbacks',
                        'db_table': 'feedback',
                        'ordering': ['-created_at'],
                    },
                ),
            ],
        ),
        # Add indexes (only if they don't exist)
        migrations.RunPython(
            add_indexes_if_not_exists,
            reverse_migration,
        ),
    ]

