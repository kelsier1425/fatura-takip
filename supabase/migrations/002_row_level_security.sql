-- Enable Row Level Security on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.budget_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.savings_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.savings_contributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recurring_expenses ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Categories policies
CREATE POLICY "Users can view own and system categories" ON public.categories
  FOR SELECT USING (auth.uid() = user_id OR is_system = true);

CREATE POLICY "Users can insert own categories" ON public.categories
  FOR INSERT WITH CHECK (auth.uid() = user_id AND is_system = false);

CREATE POLICY "Users can update own categories" ON public.categories
  FOR UPDATE USING (auth.uid() = user_id AND is_system = false);

CREATE POLICY "Users can delete own categories" ON public.categories
  FOR DELETE USING (auth.uid() = user_id AND is_system = false);

-- Expenses policies
CREATE POLICY "Users can view own expenses" ON public.expenses
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own expenses" ON public.expenses
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own expenses" ON public.expenses
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own expenses" ON public.expenses
  FOR DELETE USING (auth.uid() = user_id);

-- Budgets policies
CREATE POLICY "Users can view own budgets" ON public.budgets
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own budgets" ON public.budgets
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own budgets" ON public.budgets
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own budgets" ON public.budgets
  FOR DELETE USING (auth.uid() = user_id);

-- Budget notifications policies
CREATE POLICY "Users can view own budget notifications" ON public.budget_notifications
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.budgets
      WHERE budgets.id = budget_notifications.budget_id
      AND budgets.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own budget notifications" ON public.budget_notifications
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.budgets
      WHERE budgets.id = budget_notifications.budget_id
      AND budgets.user_id = auth.uid()
    )
  );

-- Savings goals policies
CREATE POLICY "Users can view own savings goals" ON public.savings_goals
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own savings goals" ON public.savings_goals
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own savings goals" ON public.savings_goals
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own savings goals" ON public.savings_goals
  FOR DELETE USING (auth.uid() = user_id);

-- Savings contributions policies
CREATE POLICY "Users can view own savings contributions" ON public.savings_contributions
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.savings_goals
      WHERE savings_goals.id = savings_contributions.goal_id
      AND savings_goals.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own savings contributions" ON public.savings_contributions
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.savings_goals
      WHERE savings_goals.id = savings_contributions.goal_id
      AND savings_goals.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own savings contributions" ON public.savings_contributions
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.savings_goals
      WHERE savings_goals.id = savings_contributions.goal_id
      AND savings_goals.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own savings contributions" ON public.savings_contributions
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.savings_goals
      WHERE savings_goals.id = savings_contributions.goal_id
      AND savings_goals.user_id = auth.uid()
    )
  );

-- Recurring expenses policies
CREATE POLICY "Users can view own recurring expenses" ON public.recurring_expenses
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own recurring expenses" ON public.recurring_expenses
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own recurring expenses" ON public.recurring_expenses
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own recurring expenses" ON public.recurring_expenses
  FOR DELETE USING (auth.uid() = user_id);