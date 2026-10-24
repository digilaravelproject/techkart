import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/affiliate_models.dart';
import '../../data/repository/affiliate_repository.dart';

// ─── Events ─────────────────────────────────────────────────────────────────

abstract class AffiliateEvent extends Equatable {
  const AffiliateEvent();

  @override
  List<Object?> get props => [];
}

class LoadAffiliateDashboard extends AffiliateEvent {
  final bool isRefresh;
  const LoadAffiliateDashboard({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class RegisterAffiliateEvent extends AffiliateEvent {
  const RegisterAffiliateEvent();
}

class RequestPayoutEvent extends AffiliateEvent {
  final double amount;
  final String? payoutMethod;
  final String? upiId;

  const RequestPayoutEvent({
    required this.amount,
    this.payoutMethod,
    this.upiId,
  });

  @override
  List<Object?> get props => [amount, payoutMethod, upiId];
}

class UpdatePayoutSettingsEvent extends AffiliateEvent {
  final String payoutMethod;
  final String? upiId;
  final String? accountNumber;
  final String? ifscCode;
  final String? accountHolder;
  final String? bankName;

  const UpdatePayoutSettingsEvent({
    required this.payoutMethod,
    this.upiId,
    this.accountNumber,
    this.ifscCode,
    this.accountHolder,
    this.bankName,
  });

  @override
  List<Object?> get props => [
    payoutMethod,
    upiId,
    accountNumber,
    ifscCode,
    accountHolder,
    bankName,
  ];
}

class SwitchAffiliateTabEvent extends AffiliateEvent {
  final int tabIndex; // 0: Transactions, 1: Commissions, 2: Payouts
  const SwitchAffiliateTabEvent(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

// ─── States ─────────────────────────────────────────────────────────────────

enum AffiliateStatus { initial, loading, success, error }

class AffiliateState extends Equatable {
  final AffiliateStatus status;
  final AffiliateDashboardData? dashboard;
  final List<AffiliateTransaction> transactions;
  final List<AffiliateCommission> commissions;
  final List<AffiliatePayout> payouts;
  final int selectedTabIndex;
  final bool isSubmittingAction;
  final String? actionSuccessMessage;
  final String? errorMessage;

  const AffiliateState({
    this.status = AffiliateStatus.initial,
    this.dashboard,
    this.transactions = const [],
    this.commissions = const [],
    this.payouts = const [],
    this.selectedTabIndex = 0,
    this.isSubmittingAction = false,
    this.actionSuccessMessage,
    this.errorMessage,
  });

  AffiliateState copyWith({
    AffiliateStatus? status,
    AffiliateDashboardData? dashboard,
    List<AffiliateTransaction>? transactions,
    List<AffiliateCommission>? commissions,
    List<AffiliatePayout>? payouts,
    int? selectedTabIndex,
    bool? isSubmittingAction,
    String? actionSuccessMessage,
    String? errorMessage,
  }) {
    return AffiliateState(
      status: status ?? this.status,
      dashboard: dashboard ?? this.dashboard,
      transactions: transactions ?? this.transactions,
      commissions: commissions ?? this.commissions,
      payouts: payouts ?? this.payouts,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      isSubmittingAction: isSubmittingAction ?? this.isSubmittingAction,
      actionSuccessMessage: actionSuccessMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    dashboard,
    transactions,
    commissions,
    payouts,
    selectedTabIndex,
    isSubmittingAction,
    actionSuccessMessage,
    errorMessage,
  ];
}

// ─── BLoC ───────────────────────────────────────────────────────────────────

class AffiliateBloc extends Bloc<AffiliateEvent, AffiliateState> {
  final AffiliateRepository repository;

  AffiliateBloc({required this.repository}) : super(const AffiliateState()) {
    on<LoadAffiliateDashboard>(_onLoadDashboard);
    on<RegisterAffiliateEvent>(_onRegisterAffiliate);
    on<RequestPayoutEvent>(_onRequestPayout);
    on<UpdatePayoutSettingsEvent>(_onUpdatePayoutSettings);
    on<SwitchAffiliateTabEvent>(_onSwitchTab);
  }

  Future<void> _onLoadDashboard(
    LoadAffiliateDashboard event,
    Emitter<AffiliateState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(state.copyWith(status: AffiliateStatus.loading, errorMessage: null));
    }

    try {
      final dashboard = await repository.getDashboard();

      // If active, pre-fetch recent records for each tab
      List<AffiliateTransaction> transactions = state.transactions;
      List<AffiliateCommission> commissions = state.commissions;
      List<AffiliatePayout> payouts = state.payouts;

      if (dashboard.isActive) {
        try {
          final txRes = await repository.getTransactions(page: 1, limit: 10);
          transactions = txRes.data;
        } catch (_) {}

        try {
          final commRes = await repository.getCommissions(page: 1, limit: 10);
          commissions = commRes.data;
        } catch (_) {}

        try {
          final payRes = await repository.getPayouts(page: 1, limit: 10);
          payouts = payRes.data;
        } catch (_) {}
      }

      emit(
        state.copyWith(
          status: AffiliateStatus.success,
          dashboard: dashboard,
          transactions: transactions,
          commissions: commissions,
          payouts: payouts,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AffiliateStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRegisterAffiliate(
    RegisterAffiliateEvent event,
    Emitter<AffiliateState> emit,
  ) async {
    emit(state.copyWith(isSubmittingAction: true, errorMessage: null));
    try {
      final res = await repository.registerAffiliate();
      if (res.success) {
        emit(
          state.copyWith(
            isSubmittingAction: false,
            actionSuccessMessage: res.message.isNotEmpty
                ? res.message
                : 'Affiliate program activated successfully!',
          ),
        );
        add(const LoadAffiliateDashboard(isRefresh: true));
      } else {
        emit(
          state.copyWith(
            isSubmittingAction: false,
            errorMessage: res.message.isNotEmpty
                ? res.message
                : 'Failed to activate affiliate program',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isSubmittingAction: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRequestPayout(
    RequestPayoutEvent event,
    Emitter<AffiliateState> emit,
  ) async {
    emit(state.copyWith(isSubmittingAction: true, errorMessage: null));
    try {
      final res = await repository.requestPayout(
        amount: event.amount,
        payoutMethod: event.payoutMethod,
        upiId: event.upiId,
      );

      if (res.success) {
        emit(
          state.copyWith(
            isSubmittingAction: false,
            actionSuccessMessage: res.message.isNotEmpty
                ? res.message
                : 'Payout requested successfully!',
          ),
        );
        add(const LoadAffiliateDashboard(isRefresh: true));
      } else {
        emit(
          state.copyWith(
            isSubmittingAction: false,
            errorMessage: res.message.isNotEmpty
                ? res.message
                : 'Payout request failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isSubmittingAction: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdatePayoutSettings(
    UpdatePayoutSettingsEvent event,
    Emitter<AffiliateState> emit,
  ) async {
    emit(state.copyWith(isSubmittingAction: true, errorMessage: null));
    try {
      final res = await repository.updatePayoutSettings(
        payoutMethod: event.payoutMethod,
        upiId: event.upiId,
        accountNumber: event.accountNumber,
        ifscCode: event.ifscCode,
        accountHolder: event.accountHolder,
        bankName: event.bankName,
      );

      if (res.success) {
        emit(
          state.copyWith(
            isSubmittingAction: false,
            actionSuccessMessage: res.message.isNotEmpty
                ? res.message
                : 'Payout details saved successfully!',
          ),
        );
        add(const LoadAffiliateDashboard(isRefresh: true));
      } else {
        emit(
          state.copyWith(
            isSubmittingAction: false,
            errorMessage: res.message.isNotEmpty
                ? res.message
                : 'Failed to save payout settings',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isSubmittingAction: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSwitchTab(
    SwitchAffiliateTabEvent event,
    Emitter<AffiliateState> emit,
  ) {
    emit(state.copyWith(selectedTabIndex: event.tabIndex));
  }
}
