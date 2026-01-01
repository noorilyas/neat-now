# Generated manually

from django.db import migrations, models
import django.db.models.deletion
import django.core.validators


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0001_initial'),
        ('gamification', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='WorkerMonthlyStats',
            fields=[
                ('stat_id', models.BigAutoField(primary_key=True, serialize=False)),
                ('month_year', models.CharField(db_index=True, help_text='Format: YYYY-MM (e.g., "2025-12")', max_length=7)),
                ('resolved_tasks', models.IntegerField(default=0, help_text='Total tasks completed in that month')),
                ('points', models.IntegerField(default=0, help_text='Total points earned this month (5 points per completed report)')),
                ('avg_rating', models.DecimalField(decimal_places=2, default=0.0, help_text='Average rating from citizens for that month (0.00 to 5.00)', max_digits=3, validators=[django.core.validators.MinValueValidator(0.0), django.core.validators.MaxValueValidator(5.0)])),
                ('badge', models.CharField(choices=[('None', 'None'), ('Bronze', 'Bronze'), ('Silver', 'Silver'), ('Gold', 'Gold'), ('Diamond', 'Diamond')], db_index=True, default='None', help_text='Badge awarded: None, Bronze, Silver, Gold, Diamond', max_length=10)),
                ('updated_at', models.DateTimeField(auto_now=True, db_index=True)),
                ('worker', models.ForeignKey(db_column='worker_id', help_text='The worker being tracked', limit_choices_to={'role': 'Worker'}, on_delete=django.db.models.deletion.CASCADE, related_name='worker_monthly_stats', to='accounts.account')),
            ],
            options={
                'verbose_name': 'Worker Monthly Stat',
                'verbose_name_plural': 'Worker Monthly Stats',
                'db_table': 'worker_monthly_stats',
                'ordering': ['month_year', '-points', '-avg_rating'],
                'unique_together': {('worker', 'month_year')},
            },
        ),
        migrations.AddIndex(
            model_name='workermonthlystats',
            index=models.Index(fields=['month_year', 'points'], name='gamif_w_month_year_points_idx'),
        ),
        migrations.AddIndex(
            model_name='workermonthlystats',
            index=models.Index(fields=['month_year', 'avg_rating'], name='gamif_w_month_year_avg_rt_idx'),
        ),
        migrations.AddIndex(
            model_name='workermonthlystats',
            index=models.Index(fields=['badge', 'month_year'], name='gamif_w_badge_month_year_idx'),
        ),
        migrations.AddIndex(
            model_name='workermonthlystats',
            index=models.Index(fields=['updated_at'], name='gamif_w_updated_at_idx'),
        ),
    ]
