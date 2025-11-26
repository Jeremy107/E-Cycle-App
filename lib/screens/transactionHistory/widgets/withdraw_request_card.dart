import 'package:e_cycle/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WithdrawRequestCard extends StatefulWidget {
  final String userId;
  final String requestKey;
  final int points;
  final String bank;
  final String accountNumber;
  final String status;
  final Timestamp? createdAt;

  const WithdrawRequestCard({
    super.key,
    required this.userId,
    required this.requestKey,
    required this.points,
    required this.bank,
    required this.accountNumber,
    required this.status,
    required this.createdAt,
  });

  @override
  State<WithdrawRequestCard> createState() => _WithdrawRequestCardState();
}

class _WithdrawRequestCardState extends State<WithdrawRequestCard> {
  bool _expanded = false;
  bool _cancelling = false;

  void _toggle() => setState(() => _expanded = !_expanded);

  Future<void> _cancel() async {
    if (_cancelling || widget.status != 'pending') return;
    setState(() => _cancelling = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid != widget.userId) {
      setState(() => _cancelling = false);
      return;
    }
    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        final withdrawDocRef = FirebaseFirestore.instance
            .collection('withdraw_requests')
            .doc(user.uid);

        // Reads first
        final userSnap = await tx.get(userRef);
        final withdrawSnap = await tx.get(withdrawDocRef);
        if (!withdrawSnap.exists) return;

        final currentPoints = (userSnap.data()?['points'] ?? 0) as int;
        final reqMap =
            withdrawSnap.data()![widget.requestKey] as Map<String, dynamic>?;

        if (reqMap == null) return;
        if (reqMap['status'] != 'pending') return;
        final pointsRequested = (reqMap['pointsRequested'] ?? 0) as int;

        // Writes
        tx.update(userRef, {'points': currentPoints + pointsRequested});
        tx.update(withdrawDocRef, {
          '${widget.requestKey}.status': 'cancelled',
          '${widget.requestKey}.cancelledAt': FieldValue.serverTimestamp(),
        });
      });
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = widget.createdAt != null
        ? DateTime.fromMillisecondsSinceEpoch(
            widget.createdAt!.millisecondsSinceEpoch,
          ).toLocal().toString().split('.').first
        : '-';

    final isPending = widget.status == 'pending';
    final statusColor = isPending
        ? Colors.orange
        : (widget.status == 'cancelled' ? Colors.red : Colors.green);

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPending
                        ? Icons.schedule_rounded
                        : (widget.status == 'cancelled'
                            ? Icons.cancel_rounded
                            : Icons.check_circle_rounded),
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Penarikan Poin",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPending
                            ? "Sedang diproses"
                            : (widget.status == 'cancelled'
                                ? "Dibatalkan"
                                : "Berhasil diproses"),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                      letterSpacing: .5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Tanggal: $dateStr",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 16,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Jumlah: ",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "${widget.points} poin",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Detail Penarikan",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _detailRow("Bank", widget.bank),
                    const SizedBox(height: 8),
                    _detailRow("No Rekening", widget.accountNumber),
                    const SizedBox(height: 8),
                    _detailRow("Status", widget.status.toUpperCase()),
                  ],
                ),
              ),
              if (isPending) ...[
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _cancelling ? null : _cancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red.shade700,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.red.shade200),
                      ),
                    ),
                    child: _cancelling
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Membatalkan...",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.cancel_rounded,
                                size: 18,
                                color: Colors.red.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "BATALKAN",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? 'Tutup detail' : 'Lihat detail',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
