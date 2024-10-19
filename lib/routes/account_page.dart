import "package:flow/data/money_flow.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/routes/error_page.dart";
import "package:flow/widgets/category/transactions_info.dart";
import "package:flow/widgets/flow_card.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/grouped_transaction_list.dart";
import "package:flow/widgets/home/transactions_date_header.dart";
import "package:flow/widgets/no_result.dart";
import "package:flow/widgets/time_range_selector.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class AccountPage extends StatefulWidget {
  static const EdgeInsets _defaultHeaderPadding = EdgeInsets.fromLTRB(
    16.0,
    16.0,
    16.0,
    8.0,
  );

  final int accountId;
  final TimeRange? initialRange;

  final EdgeInsets headerPadding;
  final EdgeInsets listPadding;

  const AccountPage({
    super.key,
    required this.accountId,
    this.initialRange,
    this.listPadding = const EdgeInsets.symmetric(vertical: 16.0),
    this.headerPadding = _defaultHeaderPadding,
  });

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool busy = false;

  QueryBuilder<Transaction> qb(TimeRange range) => ObjectBox()
      .box<Transaction>()
      .query(
        Transaction_.account.equals(account!.id).and(
              Transaction_.transactionDate.betweenDate(
                range.from,
                range.to,
              ),
            ),
      )
      .order(Transaction_.transactionDate, flags: Order.descending);

  late Account? account;

  late TimeRange range;

  @override
  void initState() {
    super.initState();

    account = ObjectBox().box<Account>().get(widget.accountId);
    range = widget.initialRange ?? TimeRange.thisMonth();
  }

  @override
  Widget build(BuildContext context) {
    if (this.account == null) return const ErrorPage();

    final Account account = this.account!;

    return StreamBuilder<List<Transaction>>(
      stream: qb(range)
          .watch(triggerImmediately: true)
          .map((event) => event.find()),
      builder: (context, snapshot) {
        final List<Transaction>? transactions = snapshot.data;

        final bool noTransactions = (transactions?.length ?? 0) == 0;

        final MoneyFlow flow = transactions?.flow ?? MoneyFlow();
        final double totalIncome =
            flow.getIncomeByCurrency(account.currency).amount;
        final double totalExpense =
            flow.getExpenseByCurrency(account.currency).amount;

        const double firstHeaderTopPadding = 0.0;

        final Widget header = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TimeRangeSelector(
              initialValue: range,
              onChanged: onRangeChange,
            ),
            const SizedBox(height: 8.0),
            TransactionsInfo(
              count: transactions?.length,
              flow: totalIncome + totalExpense,
              icon: account.icon,
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: FlowCard(
                    flow: totalIncome,
                    type: TransactionType.income,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: FlowCard(
                    flow: totalExpense,
                    type: TransactionType.expense,
                  ),
                ),
              ],
            ),
          ],
        );

        final EdgeInsets headerPaddingOutOfList = widget.headerPadding +
            widget.listPadding.copyWith(bottom: 0, top: 0) +
            const EdgeInsets.only(top: firstHeaderTopPadding);

        return Scaffold(
          appBar: AppBar(
            title: Text(account.name),
            actions: [
              IconButton(
                icon: const Icon(Symbols.edit_rounded),
                onPressed: () => edit(),
                tooltip: "general.edit".t(context),
              ),
            ],
          ),
          body: SafeArea(
            child: switch (busy) {
              true => Padding(
                  padding: headerPaddingOutOfList,
                  child: Column(
                    children: [
                      header,
                      const Expanded(child: Spinner.center()),
                    ],
                  ),
                ),
              false when noTransactions => Padding(
                  padding: headerPaddingOutOfList,
                  child: Column(
                    children: [
                      header,
                      const Expanded(child: NoResult()),
                    ],
                  ),
                ),
              _ => GroupedTransactionList(
                  header: header,
                  transactions: transactions?.groupByDate() ?? {},
                  listPadding: widget.listPadding,
                  headerPadding: widget.headerPadding,
                  firstHeaderTopPadding: firstHeaderTopPadding,
                  headerBuilder: (range, rangeTransactions) =>
                      TransactionListDateHeader(
                    transactions: rangeTransactions,
                    date: range.from,
                  ),
                )
            },
          ),
        );
      },
    );
  }

  void onRangeChange(TimeRange newRange) {
    setState(() {
      range = newRange;
    });
  }

  Future<void> edit() async {
    await context.push("/account/${account!.id}/edit");

    account = ObjectBox().box<Account>().get(widget.accountId);

    if (mounted) {
      setState(() {});
    }
  }
}
