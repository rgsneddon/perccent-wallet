/// Standalone stub — no encrypted Mishi bridge in the public wallet build.
class FcgMishiBridgeStore {
  Future<void> upsertModeratorVerifier({
    required String username,
    required String salt,
    required String passwordHash,
  }) async {}
}