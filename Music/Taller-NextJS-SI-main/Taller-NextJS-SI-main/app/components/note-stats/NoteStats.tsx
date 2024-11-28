"use client";

import { NoteData } from "../../types/Note";

interface NoteStatsProps {
    notes: NoteData[];
}

const NoteStats = ({ notes }: NoteStatsProps) => {
    const totalNotes = notes.length;
    const notesByCategory = notes.reduce(
        (acc, note) => {
            acc[note.category] = (acc[note.category] || 0) + 1;
            return acc;
        },
        {} as { [key: number]: number }
    );

    return (
        <div className="p-6 bg-primaryBlack text-neonGreen rounded-lg shadow-lg w-full md:max-w-md">
            <h2 className="text-2xl font-bold mb-4">Estadísticas</h2>
            <div className="flex flex-col space-y-3">
                <div className="flex justify-between">
                    <span className="font-medium">Total de notas:</span>
                    <span className="font-bold text-emeraldGreen">{totalNotes}</span>
                </div>
                <div className="flex justify-between">
                    <span className="font-medium">Ideas:</span>
                    <span className="font-bold text-emeraldGreen">{notesByCategory[1] || 0}</span>
                </div>
                <div className="flex justify-between">
                    <span className="font-medium">Por hacer:</span>
                    <span className="font-bold text-orangeAccent">{notesByCategory[2] || 0}</span>
                </div>
                <div className="flex justify-between">
                    <span className="font-medium">Terminado:</span>
                    <span className="font-bold text-blueAccent">{notesByCategory[3] || 0}</span>
                </div>
            </div>
        </div>
    );
};

export default NoteStats;
